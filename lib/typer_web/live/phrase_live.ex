defmodule TyperWeb.PhraseLive do
  use TyperWeb, :live_view
  require Logger
  alias Typer.Game

  @impl true
  def render(assigns) do
    elapsed = elapsed_time(assigns.start_time, assigns.end_time)
    assigns = assign(assigns, :elapsed, elapsed)

    ~H"""
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
               data-show-elixir={@show_elixir |> to_string()}
               style="position: relative; z-index: 2; background: transparent; white-space: pre-wrap;"
               phx-change="process_input">
            <span style="display: inline;" id="remaining-text"><%= render_typing_area(@phrase, @user_input, @error_positions) %></span>
          </div>

          <br>

          <div id="completion-message" phx-update="ignore" class="completion-message"></div>
          <%= if @accepted_cookies do %>
            <!-- <a href="/toggle_show_elixir" id="elixir-toggle" class="buttonly" style="color: Silver; background-color: DarkRed;" phx-click="toggle_show_elixir">Toggle Elixir Version</a> -->
          <% else %>
            <p>Accept cookies to toggle elixir view</p>
          <% end %>
          <%= if @show_elixir do %>
            <div class="elixir-content">
              <%= if @completed do %>
                <div>Final time: <%= @elapsed %> seconds</div>
              <% else %>
                Elapsed time: <%= @elapsed %> seconds
              <% end %>
              <div id="elixir-content">
                <pre><code class="elixir-content"><%= render_typing_area(@phrase, @user_input, @error_positions) %></code></pre>
              </div>
            </div>
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
    IO.inspect(session, label: "Session")
    current_user = fetch_current_user_for_liveview(session)
    dark_mode = session["dark_mode"] || false
    show_elixir = session["show_elixir"] || false
    new_user = Map.get(session, "accepted_cookies", false)

    updated_socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:user_input, "")
      |> assign(:error_positions, [])
      |> assign(:start_time, nil)
      |> assign(:end_time, nil)
      |> assign(:completed, false)
      |> assign(:accepted_cookies, new_user)
      |> assign(:comparison_results, [])
      |> assign(:show_elixir, show_elixir)
      |> assign(:dark_mode, dark_mode)

    case id_param do
      "0" ->
        # Handle the custom phrase case
        custom_phrase = session["custom_phrase"] || "Default custom phrase"
        phrase = %Typer.Game.Phrase{text: custom_phrase, id: nil}
        associated_post = get_associated_post(phrase)
        leaderboard = Game.get_leaderboard_for_phrase(phrase.id)

        {:ok, assign(updated_socket, phrase: phrase, associated_post: associated_post, leaderboard: leaderboard)}

      id ->
        # Normal case for fetching a phrase by its database ID
        phrase = Game.get_phrase!(id)
        associated_post = get_associated_post(phrase)
        leaderboard = Game.get_leaderboard_for_phrase(phrase.id)

        {:ok, assign(updated_socket, phrase: phrase, associated_post: associated_post, leaderboard: leaderboard)}
    end
  end

  defp split_into_lines(phrase) do
    phrase
    |> String.split("\n") # Split by newline characters
  end

  defp render_typing_area(phrase, user_input, error_positions) do
    phrase_lines = split_into_lines(phrase.text |> String.trim())
    user_input_lines = split_into_lines(user_input)

    rendered_lines = Enum.with_index(phrase_lines)
    |> Enum.map(fn {phrase_line, line_index} ->
      user_input_line = Enum.at(user_input_lines, line_index, "")
      render_line(phrase_line, user_input_line, error_positions)
    end)

    Enum.join(rendered_lines, "\n") |> Phoenix.HTML.raw()
  end

  defp render_line(phrase_line, user_input_line, error_positions) do
    phrase_graphemes = String.graphemes(phrase_line)
    input_graphemes = String.graphemes(user_input_line)

    Enum.with_index(phrase_graphemes)
    |> Enum.map(fn {char, index} ->
      user_char = Enum.at(input_graphemes, index)
      class = cond do
        user_char == nil -> "incomplete"
        user_char == char -> "correct"
        index in error_positions -> "error"
        true -> "incorrect"
      end

      Phoenix.HTML.Tag.content_tag(:span, char, class: class) |> Phoenix.HTML.safe_to_string()
    end)
    |> Enum.join()
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
    %{phrase: phrase, start_time: start_time} = socket.assigns

    # Set start_time if it's the first input
    start_time = start_time || DateTime.utc_now()

    error_positions = calculate_error_positions(phrase.text, user_input)
    finished_typing = user_input == phrase.text
    IO.puts("Finished typing: #{finished_typing}")

    socket = socket
      |> assign(:user_input, user_input)
      |> assign(:start_time, start_time)
      |> assign(:end_time, if(finished_typing, do: DateTime.utc_now(), else: nil))
      |> assign(:completed, finished_typing)
      |> assign(:error_positions, error_positions)

    if finished_typing do
      IO.puts("Typing completed. Recording attempt...")
      updated_socket = record_attempt(socket)
      {:noreply, updated_socket}
    else
      {:noreply, socket}
    end
  end

  defp record_attempt(socket) do
    IO.puts("Inside record_attempt function")
    %{phrase: phrase, current_user: current_user, start_time: start_time, end_time: end_time} = socket.assigns

    case {start_time, end_time} do
      {nil, _} ->
        IO.puts("Start time is nil. Cannot record attempt.")
        socket |> put_flash(:error, "Cannot record attempt: Start time not set.")

      {_, nil} ->
        IO.puts("End time is nil. Cannot record attempt.")
        socket |> put_flash(:error, "Cannot record attempt: End time not set.")

      {start_time, end_time} ->
        elapsed_time = DateTime.diff(end_time, start_time, :millisecond) / 1000
        wpm = calculate_wpm(phrase.text, elapsed_time)
        accuracy = calculate_accuracy(phrase.text, socket.assigns.user_input)

        attempt_params = %{
          user_id: current_user.id,
          phrase_id: phrase.id,
          wpm: trunc(wpm),
          accuracy: trunc(accuracy)
        }

        IO.inspect(attempt_params, label: "Attempt params")

        case Game.create_phrase_attempt(attempt_params) do
          {:ok, attempt} ->
            IO.inspect(attempt, label: "Created attempt")
            socket
            |> put_flash(:info, "Attempt recorded successfully!")
            |> assign(:leaderboard, Game.get_leaderboard_for_phrase(phrase.id))
          {:error, changeset} ->
            IO.inspect(changeset, label: "Failed to create attempt")
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
  def handle_event("toggle_show_elixir", _params, socket) do
    current_mode = socket.assigns.show_elixir || false
    new_mode = !current_mode

    {:noreply, assign(socket, show_elixir: new_mode)}
  end

  def handle_event(event, params, socket) do
    IO.inspect(event, label: "Event")
    IO.inspect(params, label: "Params")
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
end
