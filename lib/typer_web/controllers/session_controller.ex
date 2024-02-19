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
end
