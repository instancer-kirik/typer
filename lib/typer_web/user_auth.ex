defmodule TyperWeb.UserAuth do
  use TyperWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Typer.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_typer_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  defdelegate log_in_user(conn, user, params \\ %{}), to: Accounts.Auth
  defdelegate log_out_user(conn), to: Accounts.Auth
  defdelegate fetch_current_user(conn, _opts), to: Accounts.Auth
  defdelegate redirect_if_user_is_authenticated(conn, _opts), to: Accounts.Auth
  defdelegate require_authenticated_user(conn, _opts), to: Accounts.Auth
  defdelegate require_confirmed_user(conn, _opts), to: Accounts.Auth

  def on_mount(:mount_current_user, params, session, socket) do
    Accounts.Auth.on_mount(:mount_current_user, params, session, socket)
  end

  def on_mount(:ensure_authenticated, params, session, socket) do
    Accounts.Auth.on_mount(:ensure_authenticated, params, session, socket)
  end

  def on_mount(:redirect_if_user_is_authenticated, params, session, socket) do
    Accounts.Auth.on_mount(:redirect_if_user_is_authenticated, params, session, socket)
  end

  def on_mount(:ensure_confirmed_user, params, session, socket) do
    Accounts.Auth.on_mount(:ensure_confirmed_user, params, session, socket)
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  def require_confirmed_user(conn, _opts) do
    if conn.assigns[:current_user] && conn.assigns[:current_user].confirmed_at do
      conn
    else
      conn
      |> put_flash(:error, "You must confirm your account to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/home"
end
