defmodule TyperWeb.SessionController do
  use TyperWeb, :controller
  alias TyperWeb.Router.Helpers, as: Routes

  def set_custom_phrase(conn, %{"custom_phrase" => custom_phrase}) do
    conn
    |> put_session("custom_phrase", custom_phrase)
    |> redirect(to: Routes.phrase_path(conn, :show, "0"))
  end

  def toggle_dark_mode(conn, _params) do
    current_mode = conn |> get_session("dark_mode") || false
    new_mode = !current_mode
    conn
    |> put_session("dark_mode", new_mode)
    |> redirect(to: Routes.home_path(conn, :index))
  end
  def add_hash(conn, %{"fileName" => file_name, "hash" => hash_value}) do
    # Handle the form submission.
    # For example, you might save the hash value and file name to the database.

    # After handling the submission, redirect to a confirmation page or render a response.
    text(conn, "Hash received: #{hash_value} for file #{file_name}")
  end
end
