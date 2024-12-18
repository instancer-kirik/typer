defmodule TyperWeb.UserRegistrationLive do
  use TyperWeb, :live_view

  alias Acts
  alias Acts.User
  alias Acts.Registration

  def render(assigns) do
    ~H"""
      <div class="form-container">
      <div class="mx-auto max-w-md p-4 rounded-lg bg-gray-800 shadow-lg">
        <.header class="text-center">
          Register for an account
          <:subtitle>
            Already registered?
            <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
              Sign in
            </.link>
            to your account now.
          </:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="registration_form"
          phx-submit="save"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          action={~p"/users/log_in?_action=registered"}
          method="post"
        >
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:username]} type="text" label="Username" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
          </:actions>
        </.simple_form>
        <p>it works, probably. try logging in.</p>
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>
        </div>
      </div>
      """

  end

  def mount(_params, _session, socket) do
    changeset = Registration.change_user_registration(%User{})
    socket = assign(socket, form: to_form(changeset), trigger_submit: false, check_errors: false)
    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Registration.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Acts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Registration.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true, check_errors: false) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Registration.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form, check_errors: true)
    end
  end
end
#st
