defmodule TyperWeb.HomeLive do
    use TyperWeb, :live_view

    alias Typer.Game.Phrase
    alias Typer.Game
    alias TyperWeb.Router.Helpers, as: Routes

#
    @impl true
    def render(%{loading: true} =assigns) do
        ~H"""
        <body class={if(@dark_mode, do: "dark-mode", else: "")} style= "color: dimgrey;">
        Typer is loading...
        </body>
        """

    end
    def render(assigns) do

        ~H"""
        <main class={if(@dark_mode, do: "dark-mode", else: "")}>

            <div class = "">

            <%= if not @accepted_cookies do %>
              <div class="cookie-popup">
                <p style="color: Silver;">COOKIES? (for custom_phrase storage, dark_mode, view toggle and accepted_cookies status)</p>
                <a href="/update-cookies" phx-click="accept_cookies">Accept</a>
              </div>
            <% end %>
            <h1 class="text-2x1 text-zinc-400">Typer</h1>


            <.button phx-click="navigate_to_hasher">Go to Hash Slinging Hasher</.button>

            <%= if @accepted_cookies do %>
              <!-- Render dark mode toggle -->
            <.button id="darkmode-toggle" type="button" phx-hook="DarkModeToggle" data-dark-mode={@dark_mode} >DARKMODE</.button>
            <a href="/toggle_dark_mode" class="dark-mode-toggle">Toggle Dark Mode</a>
            <a href="/toggle_show_elixir"class= "buttonly" style="color: Silver; background-color: DarkRed;">Toggle Elixir Text Rendering</a>
            <% else %>
              <!-- Show message or disabled button -->
              <button style= "color: silver;" disabled="true">Accept Cookies to Use Dark Mode</button>
           <% end %>
            <.button type="button" phx-click={show_modal("new-phrase-modal")}>Create Phrase</.button>
            <%= if @accepted_cookies do %>
            <!-- Allow submitting custom phrases -->


              <form phx-change="validate" action="/set_custom_phrase" method="post">
                  <input type="hidden" name="_csrf_token" value={@csrf_token} />
                  <textarea name="custom_phrase" type="textarea" placeholder="Enter custom phrase here"></textarea>
                  <button type="submit" disabled={@disable_submit} class="buttonly" style="background-color: rgb(100, 22, 44); color: Silver;" >Type this</button>
              </form>


            <% else %>
              <p style= "color: silver;">also for custom_phrase</p>
            <% end %>
            <div id="opts" phx-update="stream" class= " flex flex-col gap-2">
                <div :for ={{dom_id, phrase} <- @streams.phrases} id={dom_id} class = "w-full mx-auto flex flex-col gap-2 p-4 border rounded" style="font-size: 10px;">

                <a href="#" phx-click="show-phrase" phx-value-id={phrase.id}><%= phrase.text %></a>
                <!-- Delete button for each phrase  <p  ><%= phrase.user.email %></p>-->
                  <%= if @current_user && @current_user.email == "instance.select@gmail.com" do %>
                  <button phx-click="delete-phrase" phx-value-id={phrase.id}>Delete</button>
                  <% end %>
                </div>
            </div>

            <.modal id="new-phrase-modal" >
            <div class="modal-content">
            <%= if @current_user && @current_user.email == "instance.select@gmail.com" do %>
              <.simple_form for={@form} phx-submit="save-phrase" class="modal-form">
                <.input field={@form[:text]} type="textarea" label="Phrase" required />
                <.button type="submit" phx-disable-with="Saving...">Create Phrase</.button>
              </.simple_form>
              <% else %>
              <p>No public phrase approval yet.</p>
              <% end %>
            </div>
          </.modal>
          </div>


        </main>
        """
    end
#s
        @impl true
    def mount(_params, session, socket) do
      csrf_token = Plug.CSRFProtection.get_csrf_token()
      dark_mode = session["dark_mode"] || false
      current_user = Typer.Acts.get_user_from_session(session)

      IO.inspect(current_user, label: "AAAA")
      new_user = Map.get(session, "accepted_cookies", false)
      # accepted_cookies = !Map.get(session, "accepted_cookies", false)
      form = %Phrase{} |> Phrase.changeset(%{}) |> to_form(as: "phrase")

      if connected?(socket) do
        {:ok,
        socket
        |> assign(:form, form)
        |> assign(:loading, false)
        |> assign(:csrf_token, csrf_token)
        |> assign(:disable_submit, true)
        |> assign(:dark_mode, dark_mode)
        |> assign(:accepted_cookies, new_user)
        |> assign(:current_user, current_user)
        |> stream(:phrases, Game.list_phrases())}
      else
        {:ok,
        socket
        |> assign(:loading, true)
        |> assign(:csrf_token, csrf_token)
        |> assign(:disable_submit, true)
        |> assign(:dark_mode, dark_mode)
        |> assign(:accepted_cookies, new_user)}
      end
    end

    @impl true
    def handle_event("save-phrase", %{"phrase" => phrase_params}, socket) do
        %{current_user: user} = socket.assigns
        phrase_params
        |> Map.put("user_id", user.id)
        |> Game.save()
        |> case do
          {:ok, _phrase} ->
            # If the phrase is saved successfully, redirect to the phrase list page
            {:noreply, push_redirect(socket, to: Routes.home_path(socket,:index))}

          {:error, _changeset} ->
            # Handle the error case without redirections
            {:noreply, socket}
        end
    end
    def handle_event("show-phrase", %{"id" => phrase_id}, socket) do
        {:noreply, push_navigate(socket, to: Routes.phrase_path(socket, :show,phrase_id))}
    end
    def handle_event("validate", %{"custom_phrase" => custom_phrase}, socket) do
      disable_submit = custom_phrase == "" or custom_phrase == nil
      {:noreply, assign(socket, disable_submit: disable_submit)}
    end

    def handle_event("delete-phrase", %{"id" => phrase_id}, socket) do
      # Assuming you have a function `delete_phrase/1` in your `Game` context
      Game.delete_phrase(phrase_id)

      # Update the list of phrases after deletions
      phrases = Game.list_phrases()
      {:noreply, assign(socket, streams: %{phrases: phrases})}
    end
    def handle_event("toggle_dark_mode", _params, socket) do
      new_dark_mode = !socket.assigns.dark_mode
      {:noreply, assign(socket, dark_mode: new_dark_mode)}
    end
    @impl true
    def handle_event("accept_cookies", _params, socket) do
      push_patch(socket, to: Routes.session_path(socket, :update_cookies))
      {:noreply, assign(socket, accepted_cookies: false)}
    end
    @impl true
    def handle_event("navigate_to_hasher", _params, socket) do
      {:noreply, push_redirect(socket, to: Routes.hash_slinging_hasher_path(socket, :index))}
    end
      # Helper function to translate errors, adjust as necessary based on your error structure.
      # defp translate_errors(error_map) do
      #   # If `error_map` is structured like `%{text: ["error message"]}`, then you can directly use it.
      #   # If it's an Ecto.Changeset, you would use `Ecto.Changeset.traverse_errors`.
      #   Map.get(error_map, :text, [])
      # end



    def handle_custom_phrase(custom_phrase_text) do
        cond do
          custom_phrase_text in [nil, ""] ->
            {:error, %{text: ["Custom phrase cannot be empty"]}}

          byte_size(custom_phrase_text) > 4096 ->
            {:error, %{text: ["Custom phrase cannot exceed 4KB"]}}

          true ->
            {:ok, custom_phrase_text}
        end
      end






end
#JS to add to local storage, but would need to pass back to server for comparison and elixir word tracker. not it

#from elixir redirect for controller to add to session, then to PhraseLive to fetch from session if id==0
