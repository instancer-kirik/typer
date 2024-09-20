alias Typer.Game.Phrase
alias Typer.Repo
alias Typer.Accounts.User

# Create a dummy user for the phrases
{:ok, dummy_user} = %User{}
|> User.registration_changeset(%{email: "dummy@example.com", password: "dummypassword"})
|> Repo.insert()

phrases = [
  %{
    text: "<div id= \"layout-container\" class=\"layout-container\" phx-hook=\"ForceReload\">
  <div id=\"themer\" phx-hook=\"DarkModeToggle\" data-dark-mode={@dark_mode}></div>

  <div id=\"phrase-data\" data-phrase-text={@phrase.text}></div>
    <div  phx-update=\"ignore\" id=\"timer-box\">
      <div id=\"js-timer\">READY</div>
      </div>
      <div id=\"countdown\" style = \"padding= 0;\" phx-update=\"ignore\" phx-hook=\"Countdown\">3..</div>

      <!-- contenteditable div for input and styling based on correctness -->

      <div id=\"editable-container\" name=\"user_input\" phx-hook=\"EditableContainer\" phx-debounce=\"1000\" phx-update=\"ignore\" contenteditable=\"true\" spellcheck=\"false\" data-show-elixir={@show_elixir |> to_string()} style=\"position: relative; z-index: 2; background: transparent; white-space: pre-wrap;\">
     <span style = \"display: inline;\" id=\"remaining-text\"><%= render_typing_area(@phrase, @user_input) %></span>

      </div>

    <br>

    <div id=\"completion-message\" phx-update=\"ignore\" class=\"completion-message\"></div>
    <%= if @accepted_cookies do %>
    <!-- <a href=\"/toggle_show_elixir\" id = \"elixir-toggle\" class= \"buttonly\" style=\"color: Silver; background-color: DarkRed;\" phx-click=\"toggle_show_elixir\">Toggle Elixir Version</a>
    -->
    <% else %>
    <p>Accept cookies to toggle elixir view</p>
    <% end %>
    <%= if @show_elixir do %>
    <div class=\"elixir-content\">

    <%= if @completed do %>

    <div>Final time: <%= @elapsed %> seconds</div>
    <% else %>
      Elapsed time: <%= @elapsed %> seconds
    <% end %>
      <div id=\"elixir-content\">
          <pre ><code class=\"elixir-content\" ><%= render_typing_area(@phrase, @user_input) %></code></pre>
      </div>
    </div>
    <% end %>
  </div>",
    user_id: dummy_user.id
  },
  %{
    text: " if (isCorrect) {

        // Handle newline characters and tab characters for indentation
        if (correctChar === '\\n') {
          this.appendNewLine();
          // Automatically this.append indentation after new line if next characters are tabs or spaces
          this.appendIndentation();
        } else if (correctChar === '\\t') {
          this.appendTab();
        } else {
          this.appendChar(char, true);
        }
        this.typedLength++;
        this.moveCaretBeforeRemainingText();
        this.updateRemainingText();
      } else {
        if (correctChar === '\\n') {
          this.appendNewLine();
          // Automatically this.append indentation after new line if next characters are tabs or spaces
          this.appendIndentation();
        } else if (correctChar === '\\t') {
          this.appendTab();
        } else if(char === \" \") {
          char = \"▄\";
          this.appendChar(char, false);

        }else{
          this.appendChar(char, false);
        }
        this.typedLength++;
        this.moveCaretBeforeRemainingText();
        this.updateRemainingText();
      }",
    user_id: dummy_user.id
  },
  %{
    text: "
   This is Typer. It allows you to type and test for long phrases up to 4KB, supporting multi-line code blocks. It works in javascript, and a version in elixir that runs much more laggy, because each keypress takes a round-trip to the server to be verified and rerendered. The line wrapping was a little difficult, because the textarea by default consumes the spaces on the outside. And in order for me to do that, I have to calculate the width and manually add zero width spaces, or something. But now I just render a single contenteditable div. It calculates your time and words per minute accurately in both javascript and elixir, so I like to see when they differ.

    ",
    user_id: dummy_user.id
  }
]

Enum.each(phrases, fn phrase_data ->
  %Phrase{}
  |> Phrase.changeset(phrase_data)
  |> Repo.insert!()
end)
