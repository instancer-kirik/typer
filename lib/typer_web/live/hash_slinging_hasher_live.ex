defmodule TyperWeb.HashSlingingHasherLive do

  use TyperWeb, :live_view
  # alias Typer.Game.Phrase
  alias Typer.HashData
  # alias TyperWeb.Router.Helpers, as: Routes
  @impl true
  def render(%{loading: true} =assigns) do
      ~H"""
      <body class={if(@dark_mode, do: "dark-mode", else: "")}>
      HashSlingingHasher is loading...
      </body>
      """

  end
  def render(assigns) do
    ~H"""
    <h1>Hash Slinging Hasher</h1>
    <div id="content">
        <form>
            <input type="file" id="fileInput" multiple>
            <button type="button" class="buttonly" id="calculateHashButton" phx-hook="HashCalculator">Analysis</button>
        </form>
        <div id="custom_phrase" phx-update="ignore"></div>



        <form id="customPhraseForm" action="/set_custom_phrase" method="post">
          <input type="hidden" name="custom_phrase" id="custom_phrase_hidden" value={@custom_phrase}>
          <input type="hidden" name="_csrf_token" value={@csrf_token} />
          <%= if @accepted_cookies do %>
          <button type="submit" class="buttonly">Type the Hash</button>
          <% else %>
          <p>Accept cookies to type this(uses custom_phrase)</p>
          <% end %>
        </form>



        <br>
        <div id="message">
          <%= @message %>
        </div>

    </div>
    """
  end
  @impl true
def mount(_params, session, socket) do
    current_user = Typer.Acts.get_user_from_session(session) || nil
    accepted_cookies = Map.get(session, "accepted_cookies", false)
    csrf_token = Plug.CSRFProtection.get_csrf_token()
    dark_mode = session[:dark_mode] || true
    IO.inspect(session["dark_mode"], label: "Dark Mode Session Value")
    if connected?(socket) do


    socket=
        socket
        |> assign( loading: false,csrf_token: csrf_token, dark_mode: dark_mode, message: nil, disable_submit: true, custom_phrase: "", accepted_cookies: accepted_cookies, current_user: current_user)

 {:ok, socket}
    else
        {:ok, assign(socket, loading: true,csrf_token: csrf_token, dark_mode: dark_mode, message: nil, disable_submit: true, custom_phrase: "", accepted_cookies: accepted_cookies)}
    end
end
@impl true
def handle_event("hash_calculated", %{"hash" => hash, "fileName" => file_name} = _params, socket) do
  # Assuming `current_user.id` is available. Adjust accordingly if not.<form phx-change="validate" action="/set_custom_phrase" method="post">   </form>disabled={@disable_submit}
  user_id = socket.assigns.current_user && socket.assigns.current_user.id

  hash_params = %{
    hash: hash,
    app_title: file_name, # Assuming you have a field for the file name, adjust as necessarys
    user_id: user_id
  }
  # IO.inspect(hash_params, label: "AAAAAAAAAAAAA")
  case HashData.save_hash(hash_params) do
    {:ok, _hash_data} ->
      {:noreply, assign(socket, message: "Built different. Save successful." ,custom_phrase: hash, disable_submit: false)}
    {:error, {:exists, existing_file_name}} ->
      message = if file_name == existing_file_name do
          "Unfortunately not built different. "<> Phoenix.HTML.safe_to_string(Phoenix.HTML.html_escape(existing_file_name))<> " is already here. Try again after editing."
        else
          "Unfortunately not built different.<br>Seen: "<> Phoenix.HTML.safe_to_string(Phoenix.HTML.html_escape(existing_file_name))
        end
      {:noreply, assign(socket, message: Phoenix.HTML.raw(message), custom_phrase: hash, disable_submit: false)}
    # {:error, {:exists, existing_file_name}} ->
    #   message = if file_name == existing_file_name do
    #   message = "Unfortunately not built different.<br> Seen: "<> Phoenix.HTML.safe_to_string(Phoenix.HTML.html_escape(existing_file_name))
    #   {:noreply, assign(socket, message: Phoenix.HTML.raw(message))}

    {:error, :invalid_hash} ->
      # Handle the :invalid_hash case specifically
      {:noreply, assign(socket, message: "Invalid hash provided.")}
      {:error, changeset} when is_map(changeset) ->
        # Here, you know changeset is an Ecto changeset, so you can safely access changeset.errors
        # Adapt this part according to how you want to display changeset errors
        error_message = "There was an error saving the hash: " <> inspect(changeset.errors)
        {:noreply, assign(socket, message: error_message,custom_phrase: hash, disable_submit: false)}
  end
end

def handle_event(event, params, socket) do
  IO.inspect(event, label: "Event")
  IO.inspect(params, label: "Params")
  {:noreply, socket}
end



end
#<div id="content">s
# <form id="hashForm" action="/add-hash" method="POST" enctype="multipart/form-data"
# phx-post="/add-hash" hx-target="#hashResults" hx-swap="outerHTML">
# <input type="hidden" name="fileName" id="fileName">
# <input type="hidden" name="hash" id="hash">
# <input type="file" id="fileInput" multiple>
# <button type="button" hx-trigger="click">Calculate Hash and Submit</button>
# </form>
# <div id="hashResults">

# <%= @message %>

# </div>
# </div>

# <script>
# document.getElementById('hashForm').addEventListener('click', function(event) {
# if (event.target.type === 'button') {
#   event.preventDefault(); // Prevent default to manually handle the submission
#   const fileInput = document.getElementById('fileInput');
#   const files = fileInput.files;
#   if (files.length === 0) {
#       alert("Please select a file.");
#       return;
#   }
#   const file = files[0];
#   file.arrayBuffer().then(arrayBuffer => {
#       return crypto.subtle.digest('SHA-256', arrayBuffer);
#   }).then(hashBuffer => {
#       const hashArray = Array.from(new Uint8Array(hashBuffer));
#       const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
#       document.getElementById('fileName').value = file.name;
#       document.getElementById('hash').value = hashHex;
#       // Now, manually triggering the form submission via HTMX
#       htmx.trigger('#hashForm', 'submit');
#   });
# }
# });
# </script>
