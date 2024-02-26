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
    case id_param do
      "0" ->
        # Handle the custom phrase case
        # This could involve retrieving a custom phrase from the session, a temporary storage, or defaulting to a predefined phrase
        custom_phrase = session["custom_phrase"] || "Default custom phrase"
        phrase = %Typer.Game.Phrase{text: custom_phrase, id: nil}

        {:ok, assign(socket, phrase: phrase, user_input: "", error_positions: [], start_time: nil, end_time: nil, completed: false, comparison_results: [])}


      id ->
        # Normal case for fetching a phrase by its database ID
        phrase = Game.get_phrase!(id)
        {:ok, assign(socket, phrase: phrase, user_input: "", error_positions: [], start_time: nil, end_time: nil, completed: false, comparison_results: [])}

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
  elapsed = elapsed_time(assigns.start_time, assigns.end_time)
  assigns = assign(assigns, :elapsed, elapsed)
  #is_completed = assigns.user_input == assigns.phrase.textssrs
  ~H"""
  <form class="typing-area" phx-change="input" phx-submit="submit">
  <pre><code><textarea class="typing-area" id="code-editor" name="user_input" phx-debounce="1000"></textarea></code></pre>

    </form>
  <!-- JavaScript Managed Area  -->
    <div id="phrase-data" data-phrase-text={@phrase.text}></div>
    <div  phx-update="ignore" id="js-text-area">
    <div id="js-timer">READY</div>
    <pre class = "typing-area">
    <code class="typing-area" id="js-typing-area"  data-phrase={@phrase.text}>
      <!-- Your code snippet here. If the text "aa" is meant to be the phrase, ensure it's placed correctly. -->

    </code></pre>
    </div>

  <div id="typing-area">
    <pre class="typing-area2"><code ><%= render_typing_area(@phrase, @user_input) %></code></pre>
  </div>

  """



  end

  defp compare_input(user_input, phrase) do
    user_input
    |> String.graphemes()
    |> Enum.zip(String.graphemes(phrase.text))
    |> Enum.map(fn
      {input_char, expected_char} when input_char == expected_char -> {input_char, true}
      {input_char, _expected_char} -> {input_char, false}
      nil -> {" ", false} # Adjust as needed for handling end of input
    end)
  end

  defp split_into_lines(phrase) do
    phrase
    |> String.split("\n") # Split by newline character
  end
  defp render_typing_area(phrase, user_input) do
    phrase_lines = split_into_lines(phrase.text)
    user_input_lines = split_into_lines(user_input)

    rendered_lines = Enum.with_index(phrase_lines)
    |> Enum.map(fn {phrase_line, line_index} ->
      user_input_line = Enum.at(user_input_lines, line_index, "")
      render_line(phrase_line, user_input_line)
    end)

    # Join the rendered lines with a delimiter suitable for HTML, such as a div or br for new lines
    html_content = Enum.join(rendered_lines, "\n") |> Phoenix.HTML.raw()

    html_content
  end
  defp render_line(phrase_line, user_input_line) do
    # Logic to render a single line comparing phrase_line and user_input_line
    # This should return a string or a safe HTML structure.
    # Example:
    phrase_graphemes = String.graphemes(phrase_line)
    input_graphemes = String.graphemes(user_input_line)
    IO.inspect( phrase_graphemes, label: "rendering ");
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
  defp extract_safe_content({:safe, content}), do: content
  defp extract_safe_content(other), do: other
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
    {:noreply, assign(socket, user_input: input)}
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
