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

        {:ok, assign(socket, phrase: phrase, user_input: "", error_positions: [], start_time: nil, end_time: nil, completed: false)}


      id ->
        # Normal case for fetching a phrase by its database ID
        phrase = Game.get_phrase!(id)
        {:ok, assign(socket, phrase: phrase, user_input: "", error_positions: [], start_time: nil, end_time: nil, completed: false)}

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
  #is_completed = assigns.user_input == assigns.phrase.text

  ~H"""
    <h2>Phrase Details</h2>
    <.button type="button" phx-click={JS.dispatch("toogle-darkmode")}>DARKMODE</.button>


    <!-- Elixir managed Area -->
    <div id="typing-area" class="">
    <div>Elixir elapsed time: <%= @elapsed %> seconds </div>
    <%= render_typing_area(@phrase.text, @user_input, @error_positions) %>
    </div>


    <!-- JavaScript Managed Area  -->

    <div phx-update="ignore" id="js-text-area">
    <div id="js-timer">READY</div>
    <div id="js-typing-area" class="typing-area" data-phrase={@phrase.text}></div>
    </div>




    <div id="input_container">
      <input type="text" readonly={@completed} phx-hook="AutoFocus" id="user_input" phx-keyup="process_input" name="user_input" value={@user_input}/>

    </div>



    """
  end

  defp render_typing_area(phrase, user_input, _error_positions) do
    phrase_codepoints = String.codepoints(phrase)
    user_input_codepoints = String.codepoints(user_input)

    html_content = phrase_codepoints
    |> Enum.with_index()
    |> Enum.map(fn {char, index} ->
      user_char = Enum.at(user_input_codepoints, index)

      # Determine the display character
      display_char =
        if char == " " and user_char != nil and user_char != char, do: "␣", else: char

      class =
        cond do
          user_char != nil and user_char != char -> "error"
          index == String.length(user_input) -> "current"
          true -> ""
        end

      # Apply a special class for spaces if they are not yet typed or correctly typed,
      # to maintain their visibility if styled with CSS.
      space_class = if char == " ", do: "space", else: ""

      "<span class=\"#{class} #{space_class}\">#{display_char}</span>"
    end)
    |> Enum.join()

    Phoenix.HTML.raw(html_content)
  end

  @impl true
  def handle_event("process_input", %{"value" => new_input}, socket) do

    error_positions = calculate_error_positions(socket.assigns.phrase.text, new_input)
    finished_typing = new_input == socket.assigns.phrase.text

    # Check if the phrase has already been completed to avoid restarting the timer
    if socket.assigns.completed do
      # If already completed, just update the user_input and other assigns without altering the timer
      {:noreply, assign(socket, user_input: new_input, error_positions: error_positions)}
  else
      start_time = socket.assigns.start_time || DateTime.utc_now()
      end_time = if finished_typing, do: DateTime.utc_now(), else: nil
      # If not completed, update all relevant assigns including the timer
      updated_socket =
        assign(socket, user_input: new_input, error_positions: error_positions,
              start_time: start_time, end_time: end_time,
              completed: finished_typing)

      {:noreply, updated_socket}
    end
  end



  # defp elapsed_time(start_time, end_time) do
  #   case {start_time, end_time} do
  #     {nil, _} -> 0
  #     {_, nil} ->
  #       # Calculate the elapsed time from start_time to the current moment
  #       DateTime.diff(DateTime.utc_now(), start_time, :second)
  #     {_, _} ->
  #       # Calculate the elapsed time between start_time and end_time
  #       DateTime.diff(end_time, start_time, :second)
  #   end
  # end

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
