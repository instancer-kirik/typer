alias Typer.Game.Phrase
alias Typer.Repo
alias Typer.Acts.User

# Create a dummy user for the phrases
{:ok, dummy_user} = %User{}
|> User.registration_changeset(%{email: "dummy@example.com", username: "dummy", password: "dummypassword"})
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
  },
  %{
    text: "Not working on mobile - doesn't register keydown or keypress events. Only 'input'. Show support and desire for refactor.",
    user_id: dummy_user.id
  },
  %{
    text: "A short phrase for your demonstration",
    user_id: dummy_user.id
  },
  %{
    text: "This is Typer. It allows you to type and test for long phrases up to 4KB, supporting multi-line code blocks. It works in javascript, and a version in elixir that runs much more laggy, because each keypress takes a round-trip to the server to be verified and rerendered. The line wrapping was a little difficult, because the textarea by default consumes the spaces on the outside. And in order for me to do that, I have to calculate the width and manually add zero width spaces, or something. But now I just render a single contenteditable div. It calculates your time and words per minute accurately in both javascript and elixir, so I like to see when they differ.",
    user_id: dummy_user.id
  },
  %{
    text: "My dog is off her leash, and she has a gun; so if she gets shot, you better run because she's also invincible. But she's friendly, and she's never barked first when greeting another dog. So she probably won't shoot first either",
    user_id: dummy_user.id
  },
  %{
    text: "If Sisyphus is rolling a boulder up a hill on a train track and midway up there a switch to divert his course to roll directly over the newly refurbished ship of Theseus with the matching vin and a salvage title instead of the default 'original'. What would you do and who would you tell?",
    user_id: dummy_user.id
  },
  %{
    text: "appendChar(char, isCorrect) { const charSpan = document.createElement('span'); charSpan.textContent = char; charSpan.className = isCorrect ? 'correct' : 'incorrect'; this.remainingTextSpan.parentNode.insertBefore(charSpan, this.remainingTextSpan); },",
    user_id: dummy_user.id
  },
  %{
    text: "if (isCorrect) { // Handle newline characters and tab characters for indentation if (correctChar === '\\n') { this.appendNewLine(); // Automatically this.append indentation after new line if next characters are tabs or spaces this.appendIndentation(); } else if (correctChar === '\\t') { this.appendTab(); } else { this.appendChar(char, true); } this.typedLength++; this.moveCaretBeforeRemainingText(); this.updateRemainingText(); } else { if (correctChar === '\\n') { this.appendNewLine(); // Automatically this.append indentation after new line if next characters are tabs or spaces this.appendIndentation(); } else if (correctChar === '\\t') { this.appendTab(); } else if(char === \" \") { char = \"▄\"; this.appendChar(char, false); }else{ this.appendChar(char, false); } this.typedLength++; this.moveCaretBeforeRemainingText(); this.updateRemainingText(); }",
    user_id: dummy_user.id
  },
  %{
    text: "const file = files[0]; file.arrayBuffer().then(arrayBuffer => { console.log(\"File loaded into array buffer. Calculating hash.\"); return crypto.subtle.digest('SHA-256', arrayBuffer); }).then(hashBuffer => { console.log(\"Hash calculated. Converting to hex string.\"); const hashArray = Array.from(new Uint8Array(hashBuffer)); const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join(''); console.log(`Hash calculated: ${hashHex}`);",
    user_id: dummy_user.id
  },
  %{
    text: "def handle_event(\"accept_cookies\", _params, socket) do push_patch(socket, to: Routes.session_path(socket, :update_cookies)) {:noreply, assign(socket, accepted_cookies: false)} end",
    user_id: dummy_user.id
  },
  %{
    text: "def handle_event(\"save\", %{\"user\" => user_params}, socket) do case Accounts.register_user(user_params) do {:ok, user} -> {:ok, _} = Accounts.deliver_user_confirmation_instructions( user, &url(~p\"/users/confirm/#{&1}\") ) changeset = Accounts.change_user_registration(user) {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)} {:error, %Ecto.Changeset{} = changeset} -> {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)} end end",
    user_id: dummy_user.id
  }
]

Enum.each(phrases, fn phrase_data ->
  %Phrase{}
  |> Phrase.changeset(phrase_data)
  |> Repo.insert!()
end)
