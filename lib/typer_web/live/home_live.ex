defmodule TyperWeb.HomeLive do
    use TyperWeb, :live_view

    alias Typer.Game.Phrase
    alias Typer.Game
    alias TyperWeb.Router.Helpers, as: Routes


    @impl true
    def render(%{loading: true} =assigns) do
        ~H"""
        <body class={if(@dark_mode, do: "dark-mode", else: "")}>
        Typer is loading...
        </body>
        """

    end
    def render(assigns) do

        ~H"""
        <main class = "dark-mode">

            <div class = "dark-mode">
            <h1 class="text-2x1">Typer</h1>
            <h1><%= "#{@dark_mode}" %></h1>

            <.button type="button" phx-click={JS.dispatch("toogle-darkmode")}>DARKMODE</.button>
            <a href="/toggle_dark_mode" class="dark-mode-toggle">Toggle Dark Mode</a>
            <.button type="button" phx-click={show_modal("new-phrase-modal")}>Create Phrase</.button>
            <form phx-change="validate" action="/set_custom_phrase" method="post">
                <input type="hidden" name="_csrf_token" value={@csrf_token} />
                <textarea name="custom_phrase" type="textarea" placeholder="Enter custom phrase here"></textarea>
                <button type="submit" disabled={@disable_submit} class="buttonly">Type this</button>
            </form>

            <div id="opts" phx-update="stream" class= " flex flex-col gap-2">
                <div :for ={{dom_id, phrase} <- @streams.phrases} id={dom_id} class = "w-full mx-auto flex flex-col gap-2 p-4 border rounded" style="font-size: 10px;">
                <p  ><%= phrase.user.email %></p>
                <a href="#" phx-click="show-phrase" phx-value-id={phrase.id}><%= phrase.text %></a>
                <!-- Delete button for each phrase -->
                  <button phx-click="delete-phrase" phx-value-id={phrase.id}>Delete</button>
                </div>
            </div>
            <.modal id="new-phrase-modal">
            <.simple_form for={@form} phx-submit= "save-phrase">
                <.input field={@form[:text]} type="textarea" label= "Phrase" required />
                <.button type="submit" phx-disable-with="Saving...">Create Phrase</.button>
            </.simple_form>
            </.modal>
            </div>
        </main>
        """
    end

    @impl true
    def mount(_params, session, socket) do

        csrf_token = Plug.CSRFProtection.get_csrf_token()
        dark_mode = session[:dark_mode] || true
        IO.inspect(session["dark_mode"], label: "Dark Mode Session Value")
        if connected?(socket) do


        form =
        %Phrase{}
        |> Phrase.changeset(%{})
        |> to_form(as: "phrase")
        socket=
            socket
            |> assign(form: form, loading: false,csrf_token: csrf_token, disable_submit: true, dark_mode: dark_mode)
            |> stream(:phrases, Game.list_phrases())
     {:ok, socket}
        else
            {:ok, assign(socket, loading: true,csrf_token: csrf_token, disable_submit: true, dark_mode: dark_mode)}
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
            # Handle the error case without redirection
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
      def handle_event("set_custom_phrase", %{"custom_phrase" => custom_phrase}, socket) do
        case handle_custom_phrase(custom_phrase) do
          {:ok, custom_phrase_text} ->
            # Custom phrase is valid. Assign it to the socket to be used in the LiveView template.
            # Ensure `custom_phrase_text` is the plain text of the custom phrase.
            {:noreply, assign(socket, phrase: custom_phrase_text, validation_errors: [])}

          {:error, error_map} ->
            # Custom phrase is invalid. Assuming `handle_custom_phrase` returns an error map directly.
            # If it's actually a changeset, you might need to adjust this part.
            errors = translate_errors(error_map) # Adjust based on actual error structure
            {:noreply, assign(socket, validation_errors: errors)}
        end
      end
      def handle_event("delete-phrase", %{"id" => phrase_id}, socket) do
        # Assuming you have a function `delete_phrase/1` in your `Game` context
        Game.delete_phrase(phrase_id)

        # Update the list of phrases after deletions
        phrases = Game.list_phrases()
        {:noreply, assign(socket, streams: %{phrases: phrases})}
      end
      def handle_event("toggle_dark_mode", _params, socket) do
        # Trigger client-side navigation to the controller action
        {:noreply, push_redirect(socket, to: "/toggle_dark_mode")}
      end

      # Helper function to translate errors, adjust as necessary based on your error structure.
      defp translate_errors(error_map) do
        # If `error_map` is structured like `%{text: ["error message"]}`, then you can directly use it.
        # If it's an Ecto.Changeset, you would use `Ecto.Changeset.traverse_errors`.
        Map.get(error_map, :text, [])
      end


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
