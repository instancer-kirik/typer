defmodule TyperWeb.UserSettingsLive do
  use TyperWeb, :live_view

  alias Typer.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address, password, and preferences</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form[:current_password].value}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@password_form[:current_password].value}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@username_form}
          id="username_form"
          phx-submit="update_username"
          phx-change="validate_username"
        >
          <.input field={@username_form[:username]} type="text" label="Username" required />
          <.input
            field={@username_form[:current_password]}
            name="current_password"
            id="current_password_for_username"
            type="password"
            label="Current password"
            value={@username_form[:current_password].value}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Username</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")
        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:page_title, "Account Settings")
      |> assign(:email_form, to_form(Accounts.change_user_email(user, %{current_password: ""})))
      |> assign(:password_form, to_form(Accounts.change_user_password(user, %{current_password: ""})))
      |> assign(:username_form, to_form(Accounts.change_user_username(user, %{current_password: ""})))
      |> assign(:trigger_submit, false)
      |> assign(:current_email, user.email)

    {:ok, socket}
  end

  def handle_event("validate_" <> field, %{"user" => params}, socket) do
    changeset =
      case field do
        "email" -> Accounts.change_user_email(socket.assigns.current_user, params)
        "password" -> Accounts.change_user_password(socket.assigns.current_user, params)
        "username" -> Accounts.change_user_username(socket.assigns.current_user, params)
      end
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :"#{field}_form", to_form(changeset))}
  end

  def handle_event("update_email", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, user_params["current_password"], user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form: to_form(Accounts.change_user_email(user, %{current_password: ""})))}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("update_password", %{"current_password" => password, "user" => user_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("update_username", %{"current_password" => password, "user" => user_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user_username(user, password, user_params) do
      {:ok, user} ->
        info = "Username updated successfully."
        changeset = Accounts.change_user_username(user)
        {:noreply,
         socket
         |> put_flash(:info, info)
         |> assign(:username_form, to_form(changeset))}

      {:error, changeset} ->
        {:noreply, assign(socket, :username_form, to_form(changeset))}
    end
  end
end
