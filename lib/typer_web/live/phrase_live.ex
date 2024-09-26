defmodule TyperWeb.PhraseLive do
  use TyperWeb, :live_view
  require Logger
  alias Typer.Game

  import Phoenix.HTML.Tag

  @max_displayed_users 5  # Limit to displaying 5 other users

  @impl true
  def render(assigns) do
    elapsed = elapsed_time(assigns.start_time, assigns.end_time)
    assigns = assign(assigns, :elapsed, elapsed)

    # Fetch associated_post if it's not in the assigns
    assigns = if Map.has_key?(assigns, :associated_post) do
      assigns
    else
      assign(assigns, :associated_post, get_associated_post(assigns.phrase))
    end

    ~H"""
    <script>function removeFadingClasses() {
      document.querySelectorAll('.fading-progress').forEach(el => {
        el.classList.remove('fading-progress');
        el.classList.remove('user-other-progress');
        el.classList.remove('user-unsigned-progress');
      });
    }

    // Call this function periodically
    setInterval(removeFadingClasses, 2000); // Run every 2 seconds
    </script>
    <div class="max-w-6xl mx-auto px-4 py-8 flex flex-col md:flex-row">
      <div class="w-full md:w-2/3 md:pr-8 mb-8 md:mb-0">
        <div id="layout-container" class="layout-container" phx-hook="ForceReload">
          <div id="themer" phx-hook="DarkModeToggle" data-dark-mode={@dark_mode}></div>

          <div id="phrase-data" data-phrase-text={@phrase.text}></div>
          <div phx-update="ignore" id="timer-box">
            <div id="js-timer">READY</div>
          </div>
          <div id="countdown" style="padding: 0;" phx-update="ignore" phx-hook="Countdown">3..</div>

          <div id="editable-container"
               phx-hook="EditableContainer"
               phx-update="ignore"
               contenteditable="true"
               spellcheck="false"
               data-show-multiplayer={@show_multiplayer |> to_string()}
               style="position: relative; z-index: 2; background: transparent; white-space: pre-wrap;"
               phx-change="process_input">
            <span style="display: inline;" id="remaining-text"><%= render_typing_area(@phrase, @user_input, @error_positions, @other_users_progress, @displayed_users, @user_identifier) %></span>
          </div>

          <br>

          <div id="completion-message" phx-update="ignore" class="completion-message"></div>
          <%= if @completed do %>
                <div>Final time: <%= @elapsed %> seconds</div>
              <% else %>
                Elapsed time: <%= @elapsed %> seconds
              <% end %>
          <%= if @current_user do %>
            <%= if @accepted_cookies do %>
              <button id="multiplayer-toggle" class="buttonly" style="color: Silver; background-color: DarkRed;" phx-click="toggle_multiplayer">
                <%= if @show_multiplayer, do: "Hide", else: "Show" %> Multiplayer View
              </button>
            <% else %>
              <p>Accept cookies to toggle multiplayer view</p>
            <% end %>
            <%= if @show_multiplayer do %>
              <div class="multiplayer-content">
                <h3>Multiplayer View</h3>
                <div id="multiplayer-content">
                  <%= render_typing_area(@phrase, @user_input, @error_positions, @other_users_progress, @displayed_users, @user_identifier) %>
                </div>
                <div>
                  <h4>Other Users Progress:</h4>
                  <%= for {user_id, progress} <- @other_users_progress do %>
                    <p>User <%= if is_binary(user_id) and String.starts_with?(user_id, "unsigned_"), do: "Anonymous", else: user_id %>: <%= progress %></p>
                  <% end %>
                </div>
              </div>
            <% end %>
          <% else %>
            <p>Sign in to access multiplayer features</p>
          <% end %>
        </div>
      </div>

      <div class="w-full md:w-1/3 md:pl-8">
        <div class="sticky top-8">
          <%= if @associated_post do %>
            <.link navigate={~p"/posts/#{@associated_post.slug}"} class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded w-full block text-center mb-4">
              Back to Post
            </.link>
          <% end %>

          <%= if @completed do %>
            <div class="bg-gray-100 shadow-lg rounded-lg overflow-hidden mt-4">
              <div class="p-4">
                <h2 class="text-2xl font-bold mb-4">Leaderboard</h2>
                <.live_component
                  module={TyperWeb.LeaderboardLive}
                  id="leaderboard"
                  leaderboard={@leaderboard}
                  show_post_title={@phrase.post_slug != nil}
                />
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id_param}, session, socket) do
    current_user = fetch_current_user_for_liveview(session)
    dark_mode = session["dark_mode"] || false
    show_multiplayer = session["show_multiplayer"] || false
    new_user = Map.get(session, "accepted_cookies", false)

    # Generate a unique session ID for unsigned users
    user_identifier = case current_user do
      %{id: id} -> id
      _ -> "unsigned_#{:crypto.strong_rand_bytes(8) |> Base.encode64()}"
    end

    case Integer.parse(id_param) do
      {id, _} ->
        case Typer.Game.get_phrase(id) do
          nil ->
            {:ok, socket |> put_flash(:error, "Phrase not found") |> push_redirect(to: "/")}

          phrase ->
            if connected?(socket) do
              Phoenix.PubSub.subscribe(Typer.PubSub, "phrase:#{phrase.id}")
            end

            associated_post = get_associated_post(phrase)

            # Remove leading, trailing, and interior blank lines from the phrase text
            cleaned_text = phrase.text
              |> String.split("\n")
              |> Enum.reject(&(String.trim(&1) == ""))
              |> Enum.join("\n")
              |> String.trim()

            trimmed_phrase = %{phrase | text: cleaned_text}

            updated_socket = socket
              |> assign(:current_user, current_user)
              |> assign(:user_identifier, user_identifier)
              |> assign(:phrase, trimmed_phrase)
              |> assign(:associated_post, associated_post)
              |> assign(:user_input, "")
              |> assign(:error_positions, [])
              |> assign(:start_time, nil)
              |> assign(:end_time, nil)
              |> assign(:completed, false)
              |> assign(:accepted_cookies, new_user)
              |> assign(:comparison_results, [])
              |> assign(:show_multiplayer, show_multiplayer)
              |> assign(:dark_mode, dark_mode)
              |> assign(:other_users_progress, %{})
              |> assign(:displayed_users, [])

            {:ok, updated_socket}
        end
      :error ->
        {:ok, socket |> put_flash(:error, "Invalid phrase ID") |> push_redirect(to: "/")}
    end
  end

  defp render_typing_area(phrase, user_input, error_positions, other_users_progress, displayed_users, current_user_identifier) do
    phrase_lines = String.split(phrase.text, "\n")
    user_input_lines = String.split(user_input, "\n")

    content = Enum.with_index(phrase_lines)
    |> Enum.map(fn {line, line_index} ->
      line_content = Enum.with_index(String.graphemes(line))
      |> Enum.map(fn {char, char_index} ->
        index = Enum.sum(Enum.map(phrase_lines |> Enum.take(line_index), &String.length/1)) + line_index + char_index
        user_char = user_input_lines |> Enum.at(line_index, "") |> String.graphemes() |> Enum.at(char_index)

        user_class = cond do
          user_char == nil -> "untyped"
          user_char == char -> "correct"
          index in error_positions -> "error"
          true -> "incorrect"
        end

        other_users_classes = Enum.map(other_users_progress, fn {user_id, progress} ->
          progress_lines = String.split(progress, "\n")
          progress_length = Enum.sum(Enum.map(progress_lines |> Enum.take(line_index), &String.length/1)) +
                            String.length(Enum.at(progress_lines, line_index, ""))
          if index == progress_length - 1 and user_id != current_user_identifier do
            cond do
              String.starts_with?(user_id, "unsigned_") -> "user-unsigned-progress"
              true -> "user-other-progress"
            end
          else
            nil
          end
        end)
        |> Enum.reject(&is_nil/1)

        all_classes = [user_class | other_users_classes] |> Enum.uniq() |> Enum.join(" ")

        Phoenix.HTML.Tag.content_tag(:span, char, class: all_classes, "data-index": index, "phx-hook": "ProgressFader")
      end)

      Phoenix.HTML.Tag.content_tag(:div, line_content, class: "typing-line")
    end)

    Phoenix.HTML.Tag.content_tag(:pre, [
      Phoenix.HTML.Tag.content_tag(:code, content)
    ])
  end

  def fetch_current_user_for_liveview(session) do
    user_token = Map.get(session, "user_token")
    user = user_token && Typer.Accounts.get_user_by_session_token(user_token)

    # Ensure a default user structure if not found; adjust according to your application needs
    user || %{}
  end

  @impl true
  def handle_event("input", %{"user_input" => user_input}, socket) do
    IO.puts("Handling input event")
    %{phrase: phrase, start_time: start_time, user_identifier: user_identifier} = socket.assigns

    # Set start_time if it's the first input
    start_time = start_time || DateTime.utc_now()

    error_positions = calculate_error_positions(phrase.text, user_input)
    finished_typing = user_input == phrase.text
    IO.puts("Finished typing: #{finished_typing}")

    # Update other_users_progress for all users
    updated_other_users_progress = Map.put(socket.assigns.other_users_progress, user_identifier, user_input)

    # Broadcast the update to all clients
    Phoenix.PubSub.broadcast(Typer.PubSub, "phrase:#{phrase.id}", {:user_progress, user_identifier, user_input})

    socket = socket
      |> assign(:user_input, user_input)
      |> assign(:start_time, start_time)
      |> assign(:end_time, if(finished_typing, do: DateTime.utc_now(), else: nil))
      |> assign(:completed, finished_typing)
      |> assign(:error_positions, error_positions)
      |> assign(:other_users_progress, updated_other_users_progress)

    # Log for debugging
    IO.inspect(user_input, label: "Received user input")
    IO.inspect(updated_other_users_progress, label: "Updated other users progress")

    if finished_typing do
      updated_socket = record_attempt(socket)
      {:noreply, updated_socket}
    else
      {:noreply, socket}
    end
  end

  defp update_displayed_users(current_displayed, current_user_id, all_progress) do
    # Always include the current user
    updated_displayed = [current_user_id | current_displayed] |> Enum.uniq()

    # Add new users if there's room
    new_users = Map.keys(all_progress) -- updated_displayed
    updated_displayed = Enum.take(updated_displayed ++ new_users, @max_displayed_users)

    # Remove users who are no longer in all_progress
    Enum.filter(updated_displayed, &Map.has_key?(all_progress, &1))
  end

  defp record_attempt(socket) do
    %{phrase: phrase, current_user: current_user, user_identifier: user_identifier, start_time: start_time, end_time: end_time} = socket.assigns

    case {start_time, end_time} do
      {nil, _} ->
        socket |> put_flash(:error, "Cannot record attempt: Start time not set.")

      {_, nil} ->
        socket |> put_flash(:error, "Cannot record attempt: End time not set.")

      {start_time, end_time} ->
        elapsed_time = DateTime.diff(end_time, start_time, :millisecond) / 1000
        wpm = calculate_wpm(phrase.text, elapsed_time)
        accuracy = calculate_accuracy(phrase.text, socket.assigns.user_input)

        attempt_params = %{
          user_id: if(is_map(current_user) and Map.has_key?(current_user, :id), do: current_user.id, else: user_identifier),
          phrase_id: phrase.id,
          wpm: trunc(wpm),
          accuracy: trunc(accuracy)
        }

        case Game.create_phrase_attempt(attempt_params) do
          {:ok, _attempt} ->
            socket
            |> put_flash(:info, "Attempt recorded successfully!")
            |> assign(:leaderboard, Game.get_leaderboard_for_phrase(phrase.id))
          {:error, changeset} ->
            socket
            |> put_flash(:error, "Failed to record attempt: #{inspect(changeset.errors)}")
        end
    end
  end

  defp calculate_wpm(text, elapsed_time_seconds) do
    words = String.split(text, ~r/\s+/) |> length()
    (words / elapsed_time_seconds) * 60 |> Float.round(2)
  end

  defp calculate_accuracy(original_text, typed_text) do
    original_chars = String.graphemes(original_text)
    typed_chars = String.graphemes(typed_text)

    correct_chars = Enum.zip(original_chars, typed_chars)
    |> Enum.count(fn {original, typed} -> original == typed end)

    (correct_chars / length(original_chars)) * 100 |> Float.round(2)
  end

  @impl true
  def handle_event("toggle_multiplayer", _params, socket) do
    current_mode = socket.assigns.show_multiplayer
    new_mode = !current_mode

    {:noreply, assign(socket, show_multiplayer: new_mode)}
  end

  def handle_event(event, params, socket) do
    {:noreply, socket}
  end

  defp maybe_complete(socket, input) do
    # If the input matches the phrase and end_time is not set, mark as completed and set end_time
    if input == socket.assigns.phrase.text && is_nil(socket.assigns.end_time) do
        socket
        |> assign(:end_time, DateTime.utc_now())
        |> assign(:completed, true)
     else
    socket
  end
end

  defp elapsed_time(start_time, end_time) do
    case {start_time, end_time} do
      {nil, _} -> 0.0
      {_, nil} ->
        diff_in_seconds(DateTime.utc_now(), start_time)
      {_, _} ->
        diff_in_seconds(end_time, start_time)
    end
  end

  defp diff_in_seconds(later_time, earlier_time) do
    DateTime.diff(later_time, earlier_time, :millisecond) / 1000.0
  end

  defp calculate_error_positions(phrase, user_input) do
    phrase_chars = String.graphemes(phrase)
    input_chars = String.graphemes(user_input)

    Enum.filter(0..min(length(phrase_chars), length(input_chars)) - 1, fn index ->
      Enum.at(phrase_chars, index) != Enum.at(input_chars, index)
    end)
  end

  defp get_associated_post(phrase) do
    case phrase.post_slug do
      nil -> nil
      slug -> Typer.Blog.get_post!(slug)
    end
  end

  @impl true
  def handle_info({:user_progress, user_identifier, user_input}, socket) do
    updated_other_users_progress = Map.put(socket.assigns.other_users_progress, user_identifier, user_input)
    IO.inspect(updated_other_users_progress, label: "Updated other_users_progress in handle_info")
    {:noreply, assign(socket, :other_users_progress, updated_other_users_progress)}
  end
end
