defmodule TyperWeb.PhraseLive do
  use TyperWeb, :live_view

  alias Typer.Game

  @impl true
  # def mount(params, _session, socket) do
  #   # Determine the phrase based on the presence of a "custom_phrase" parameter or fetch from the game logic using an "id"
  #   phrase =
  #     case params do
  #       %{"custom_phrase" => custom_phrase} when custom_phrase not in [nil, ""] ->
  #         custom_phrase
  #       %{"id" => id} ->
  #         Game.get_phrase!(id).text
  #       _ ->
  #         "Default phrase or error handling"
  #     end

  #   {:ok,
  #    assign(socket,
  #      phrase: phrase,
  #      user_input: "",
  #      error_positions: [],
  #      start_time: nil,
  #      end_time: nil,
  #      completed: false
  #    )}
  # end
  def mount(%{"id" => id_param}, session, socket) do
  #user_id = session["user_id"]
# Assuming fetch_current_user_for_liveview returns `nil` if no user is found
current_user = fetch_current_user_for_liveview(session)

# Use a conditional check to ensure current_user is not nil before accessing preferences
# show_elixir = if current_user != nil, do: Map.get(current_user.preferences, "show_elixir", true), else: true
# Assuming `current_user.preferences` is a map; adjust this example as needed
#show_elixir = get_in(current_user, [:preferences, "show_elixir"]) || true

 # Initialize `show_elixir` to `true` by default


  # Initialize show_elixir to true by default or use the value from current_user's preferences if available
  show_elixir = case current_user do
    %Typer.Accounts.User{preferences: %{"show_elixir" => preference_value}} when is_boolean(preference_value) ->
      preference_value
    _ ->
      true # Default value if preferences or show_elixir key is not set
  end
  # Fetch the current user based on the user ID from the session
  # You need to adjust the fetch_current_user function to accept the user ID as its argument
  #current_user = fetch_current_user_for_liveview(session)

   # show_elixir = Map.get(current_user.preferences, "show_elixir", true)s
    updated_socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:user_input, "")
      |> assign(:error_positions, [])
      |> assign(:start_time, nil)
      |> assign(:end_time, nil)
      |> assign(:completed, false)
      |> assign(:comparison_results, [])
      |> assign(:show_elixir, show_elixir)

      # : "",
      #
      #  ,
      #  end_time: nil,
      #  completed: false,
      #  comparison_results: [],
      #  show_elixir: show_elixir)}


    case id_param do
      "0" ->
        # Handle the custom phrase case
        # This could involve retrieving a custom phrase from the session, a temporary storage, or defaulting to a predefined phrase
        custom_phrase = session["custom_phrase"] || "Default custom phrase"
        phrase = %Typer.Game.Phrase{text: custom_phrase, id: nil}


        {:ok, assign(updated_socket, :phrase, phrase)}


      id ->
        # Normal case for fetching a phrase by its database ID
        phrase = Game.get_phrase!(id)
        {:ok, assign(updated_socket, phrase: phrase)}
# , user_input: "", error_positions: [], start_time: nil, end_time: nil, completed: false, comparison_results: [], show_elixir: show_elixir)}
    end
  end
  # def mount(%{"id" => id}, _session, socket) do
  #   phrase = Game.get_phrase!(id)
  #   {:ok, assign(socket, phrase: phrase, user_input: "", error_positions: [], start_time: nil, end_time: nil, completed: false)}
  # end
  # def mount(%{"id" => id} = params, session, socket) do
  #   # Assuming a custom phrase can be passed as a parameter
  #   custom_phrase = params["custom_phrase"] || Game.get_phrase!(id).text

  #   {:ok, assign(socket, phrase: custom_phrase, user_input: "", error_positions: [], start_time: nil, end_time: nil, completed: false)}
  # end
  @impl true
def render(assigns) do
  IO.inspect(assigns[:user_input], label: "Rendering with user_input")
  elapsed = elapsed_time(assigns.start_time, assigns.end_time)

  assigns = assign(assigns, :elapsed, elapsed)
  #is_completed = assigns.user_input == assigns.phrase.text
  # textarea.typing-area {
  #   opacity: 0; /* Make the textarea completely transparent */
  #   color: transparent; /* Make text color transparent */
  #   background-color: transparent; /* Ensure background is transparent */
  #   border: none; /* Remove the border */
  #   outline: none; /* Remove the outline */
  #   width: 100%; /* Ensure it covers the entire container */
  #   height: 100%; /* Match the height to the container */
  # }r
  # .js-content, .typing-area, #code-editor {
  #   position: absolute;
  #   top: 0;
  #   left: 0;
  #   width: 100%;
  #   height: 400px; /* Match your content height */
  #   padding: 0;
  #   box-sizing: border-box;
  # }


  # .typing-area {
  #   word-wrap: normal;
  #   word-break: normal;
  #   white-space: normal;
  #   display: block;
  #   height: auto;
  #   margin: 3px auto;
  #   line-height: 1.4;
  #   -webkit-line-clamp: 1;
  #   -webkit-box-orient: vertical;
  #   font-family: monospace; /* Ensure consistent font */
  #   font-size: 16px; /* Ensure consistent font size */
  #   width: 100%; /* Fill the container width */

  #   padding: 8px; /* Match the padding of the textarea */
  #   /* line-height: inherit; Inherit line height from parent or set explicitly */
  #   position: relative; /* Positioned relative to its normal position */
  #   z-index: 1; /* Ensure it's below the input textarea */
  # }asr

  # <div class="js-content" style="position: relative;">
  #   <!-- JavaScript Managed Area  -->
  #
  #     <div  phx-update="ignore" id="js-text-area" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;">
  #     <div class="js-typing-area" style="position: relative;">
  #     <pre style="position: absolute; top 0; left: 0; width: 100%; height: 100%; margin: 0; padding: 0; box-sizing: border-box; font-family: monospace; font-size: 10px; line-height: 120%; width: 100%; height: 100%;">
  #     <code style="position: absolute; top 0; left: 0; width: 100%; height: 100% white-space: pre-wrap;" id="js-typing-area"></code></pre>
  #     </div>
  #     </div>
  #   <form class="typing-area" phx-change="input" phx-submit="submit" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 2;">
  #   <textarea class="user-input" id="code-editor" name="user_input" phx-hook = "AutoFocus" phx-debounce="1000"
  #   style="background-color: transparent; color: transparent; border: none; width: 100%; height: 100%; font-family: monospace; font-size: 10px; line-height: 120%; box-sizing: border-box;"></textarea>
  #     </form>   # <div id="background-display" phx-update="ignore" style="position: absolute; z-index: 1; pointer-events: none;">

  ~H"""

  <div class="layout-container" >

  <div id="phrase-data" data-phrase-text={@phrase.text}></div>
    <div  phx-update="ignore" id="timer-box">
      <div id="js-timer">READY</div>
      </div>
      <div id="countdown" phx-update="ignore" phx-hook="Countdown">3..</div>
    <!-- Dynamically update this content based on input -->

    <!-- Transparent contenteditable for user input -->

      <div id="editable-container" name="user_input" phx-hook="EditableContainer" phx-debounce="1000" phx-update="ignore" contenteditable="true" data-show-elixir={@show_elixir |> to_string()} style="position: relative; z-index: 2; background: transparent; white-space: pre-wrap;">
     <span style = "display: inline;" id="remaining-text"><%= render_typing_area(@phrase, @user_input) %></span>

      </div>
    <br>
    <div id="completion-message" phx-update="ignore" class="completion-message"></div>
    <div class="toggle-container">
      <button phx-click="toggle_show_elixir">Toggle Elixir Version</button>
    </div>
    <%= if @show_elixir do %>
    <div class="elixir-content">

    <%= if @completed do %>

    <div>Final time: <%= @elapsed %> seconds</div>
    <% else %>
      Elapsed time: <%= @elapsed %> seconds
    <% end %>
      <div id="elixir-content">
          <pre ><code class="elixir-content" ><%= render_typing_area(@phrase, @user_input) %></code></pre>
      </div>
    </div>
    <% end %>
  </div>
  """



  end

  # defp compare_input(user_input, phrase) do
  #   user_input
  #   |> String.graphemes()
  #   |> Enum.zip(String.graphemes(phrase.text))
  #   |> Enum.map(fn
  #     {input_char, expected_char} when input_char == expected_char -> {input_char, true}
  #     {input_char, _expected_char} -> {input_char, false}
  #     nil -> {" ", false} # Adjust as needed for handling end of inputs
  #   end)
  # end

  defp split_into_lines(phrase) do

    phrase
    |> String.split("\n") # Split by newline characters
  end
  defp render_typing_area(phrase, user_input) do

    IO.inspect(user_input, label: "AAA")
    IO.inspect(phrase, label: "BBB")

    phrase_lines = split_into_lines(phrase.text |> String.trim())
    user_input_lines = split_into_lines(user_input)

    rendered_lines = Enum.with_index(phrase_lines)
    |> Enum.map(fn {phrase_line, line_index} ->
      user_input_line = Enum.at(user_input_lines, line_index, "")
      render_line(phrase_line, user_input_line)
    end)

    # Join the rendered lines with a delimiter suitable for HTML, such as a div or br for new lines
    html_content = Enum.join(rendered_lines) |> Phoenix.HTML.raw()

    html_content
  end
  defp render_line(phrase_line, user_input_line) do
    # Logic to render a single line comparing phrase_line and user_input_line
    # This should return a string or a safe HTML structure.
    # Example:
    phrase_graphemes = String.graphemes(phrase_line)
    input_graphemes = String.graphemes(user_input_line)
    #IO.inspect( phrase_graphemes, label: "rendering ");
    Enum.with_index(phrase_graphemes)
    |> Enum.map(fn {char, index} ->
      user_char = Enum.at(input_graphemes, index)
      class = cond do
        user_char == nil -> "incomplete"
        user_char == char -> "correct"
        user_char != char -> "error"
        true -> "incorrect"
      end

      # Return the HTML content for each character
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

  # defp render_typing_area(phrase, user_input) do
  #   comparison_results = compare_input(user_input, phrase)

  #   comparison_html = Enum.reduce(comparison_results, "", fn {char, correct}, acc ->
  #     class = if correct, do: "correct", else: "incorrect"
  #     content = extract_safe_content(char) # Ensure you're working with the content

  #     safe_string =
  #       Phoenix.HTML.html_escape(content)
  #       |> case do
  #         {:safe, iodata} -> IO.iodata_to_binary(iodata)

  #       end
  #     acc <> "<span class=\"#{class}\">#{safe_string}</span>"
  #   end)

  #   Phoenix.HTML.raw(comparison_html)
  # end
  #Below workes with code blocks and large formatted phrases safe escapes
   # defp render_typing_area(phrase, user_input) do
  #   phrase_graphemes = String.graphemes(phrase.text)
  #   input_graphemes = String.graphemes(user_input)

  #   html_content = phrase_graphemes
  #   |> Enum.with_index()
  #   |> Enum.map(fn {char, index} ->
  #     user_char = Enum.at(input_graphemes, index)
  #     class = cond do
  #       user_char == nil -> "incomplete"
  #       user_char == char -> "correct"
  #       user_char != char -> "incorrect"
  #       true -> "incorrect"
  #     end

  #     # Generate content tag for each character.
  #     Phoenix.HTML.Tag.content_tag(:span, char, class: class)
  #   end)
  #   |> Enum.map(&Phoenix.HTML.safe_to_string/1) # Convert each element to a string.
  #   |> Enum.join() # Join them into a single string.

  #   Phoenix.HTML.raw(html_content) # Mark the joined string as safe HTML.
  # end
  # def calculate_new_cursor_position(current_text, current_cursor_position) do
  #   # Split the text into lines
  #   lines = String.split(current_text, "\n", trim: true)

  #   # Find the current line based on the cursor position
  #   {current_line_index, _} = Enum.reduce_while(lines, {0, 0}, fn line, {index, pos} ->
  #     line_end_pos = pos + String.length(line) + 1 # +1 for the newline character
  #     if line_end_pos >= current_cursor_position do
  #       {:halt, {index, line_end_pos}}
  #     else
  #       {:cont, {index + 1, line_end_pos}}
  #     end
  #   end)

  #   # Calculate the start position of the next line
  #   next_line_start_pos = Enum.at(lines, 0..current_line_index)
  #   |> Enum.join("\n")
  #   |> String.length()

  #   # If the current line is the last one, keep the cursor at the end
  #   if current_line_index >= Enum.count(lines) - 1 do
  #     String.length(current_text)
  #   else
  #     next_line_start_pos + 1 # +1 to move to the start of the next line
  #   end
  # end
  # defp extract_safe_content({:safe, content}), do: content
  @impl true
  def handle_event("process_input", %{"input" => new_input}, socket) do
    error_positions = calculate_error_positions(socket.assigns.phrase.text, new_input)
    finished_typing = new_input == socket.assigns.phrase.text

    start_time = socket.assigns.start_time || DateTime.utc_now()
    end_time = if finished_typing, do: DateTime.utc_now(), else: nil

    updated_socket = assign(socket,
      user_input: new_input,
      error_positions: error_positions,
      start_time: start_time,
      end_time: end_time,
      completed: finished_typing
    )

    {:noreply, updated_socket}
  end
  @impl true
  def handle_event("handle_enter", %{"value" => value}, socket) do
    # Assuming Enter finalizes the input or triggers specific logic
    IO.inspect(value, label: "Enter Key Pressed With Value")

    # Example action: Check if the user has completed typing correctly
    if value == socket.assigns.phrase.text do
      # Mark as completed and set end time
      {:noreply, assign(socket, completed: true, end_time: DateTime.utc_now())}
    else
      # Optionally handle incorrect completion or simply return unchanged socket
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("input", %{"user_input" => input}, socket) do
    # Start the timer only if it hasn't been started yet (first input)
    start_time = socket.assigns.start_time || DateTime.utc_now()
    # Update socket with the new input, maintaining start time and recalculating end time if needed
    updated_socket =
      socket
      |> assign(:user_input, input)
      |> assign(:start_time, start_time)
      |> maybe_complete(input)

    {:noreply, updated_socket}
    #{:noreply, assign(socket, user_input: input)}
  end

  def handle_event("toggle_show_elixir", _params, socket) do
    current_user = socket.assigns.current_user
    case Typer.Accounts.toggle_show_elixir(current_user) do
      {:ok, updated_user} ->
        # Update socket's assigns as needed, e.g., with the updated user
        updated_socket =
          socket
          |> assign(:current_user, updated_user)
          |> assign(:show_elixir, not socket.assigns.show_elixir)
        {:noreply, updated_socket}

      {:error, _reason} ->
        updated_socket =
          socket
          |> assign(:show_elixir, not socket.assigns.show_elixir)
        # Handle error, e.g., log it or send a message to the user
        {:noreply, updated_socket}
    end
  end
  # def handle_event("keydown", %{"key" => "Enter", "target" => target}, socket) do
  #   # Calculate new cursor position to move to the start of the next line.
  #   # This is conceptual; your actual implementation may vary.
  #   new_cursor_position = calculate_new_cursor_position(target.value)

  #   # Broadcast a client-side event to move the cursor.
  #   # This assumes you have a custom JS hook or similar mechanism to listen to this event.
  #   push_event(socket, "move-cursor", %{position: new_cursor_position})

  #   {:noreply, socket}
  # end


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
    later_microseconds = DateTime.to_unix(later_time, :microsecond)
    earlier_microseconds = DateTime.to_unix(earlier_time, :microsecond)

    microseconds_diff = later_microseconds - earlier_microseconds

    # Convert the total microseconds difference back to seconds as a float to get fractional seconds
    total_seconds = microseconds_diff / 1_000_000.0
    Float.round(total_seconds, 2)
  end

  defp calculate_error_positions(phrase, user_input) do
    phrase_chars = String.codepoints(phrase)
    input_chars = String.codepoints(user_input)

    Enum.filter(0..min(length(phrase_chars), length(input_chars)) - 1, fn index ->
      Enum.at(phrase_chars, index) != Enum.at(input_chars, index)
    end)
  end
end
