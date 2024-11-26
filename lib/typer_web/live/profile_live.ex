defmodule TyperWeb.ProfileLive do
  use TyperWeb, :live_view

  alias Typer.Acts
  alias Typer.Stats

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <.header class="text-center">
        Profile
        <:subtitle>Your typing journey and achievements</:subtitle>
      </.header>

      <div class="mt-8 space-y-8">
        <div class="bg-white shadow rounded-lg p-6">
          <h3 class="text-lg font-medium">Personal Information</h3>
          <div class="mt-4 grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Username</label>
              <p class="mt-1 text-sm text-gray-900"><%= @current_user.username %></p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Member Since</label>
              <p class="mt-1 text-sm text-gray-900"><%= format_date(@current_user.inserted_at) %></p>
            </div>
          </div>
        </div>

        <div class="bg-white shadow rounded-lg p-6">
          <h3 class="text-lg font-medium">Recent Activity</h3>
          <div class="mt-4">
            <!-- Add recent typing sessions or achievements here -->
          </div>
        </div>
      </div>
    </div>
    """
  end

  def render(%{live_action: :stats} = assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <.header class="text-center">
        Typing Statistics
        <:subtitle>Your performance metrics and progress</:subtitle>
      </.header>

      <div class="mt-8 space-y-8">
        <div class="bg-white shadow rounded-lg p-6">
          <h3 class="text-lg font-medium">Overall Stats</h3>
          <div class="mt-4 grid grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Average WPM</label>
              <p class="mt-1 text-2xl font-semibold text-gray-900"><%= @stats.avg_wpm %></p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Accuracy</label>
              <p class="mt-1 text-2xl font-semibold text-gray-900"><%= @stats.accuracy %>%</p>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Tests Completed</label>
              <p class="mt-1 text-2xl font-semibold text-gray-900"><%= @stats.total_tests %></p>
            </div>
          </div>
        </div>

        <div class="bg-white shadow rounded-lg p-6">
          <h3 class="text-lg font-medium">Progress Chart</h3>
          <div class="mt-4 h-64">
            <!-- Add a chart component here -->
          </div>
        </div>
      </div>
    </div>
    """
  end

  def render(%{live_action: :preferences} = assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <.header class="text-center">
        Typing Preferences
        <:subtitle>Customize your typing experience</:subtitle>
      </.header>

      <div class="mt-8">
        <.simple_form for={@form} phx-submit="save_preferences">
          <div class="space-y-6">
            <div>
              <.input
                field={@form[:theme]}
                type="select"
                label="Theme"
                options={[{"Light", "light"}, {"Dark", "dark"}, {"System", "system"}]}
              />
            </div>
            <div>
              <.input
                field={@form[:sound_enabled]}
                type="checkbox"
                label="Enable Sound Effects"
              />
            </div>
            <div>
              <.input
                field={@form[:show_wpm]}
                type="checkbox"
                label="Show WPM while typing"
              />
            </div>
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Preferences</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if socket.assigns.live_action == :stats do
      stats = Stats.get_user_stats(socket.assigns.current_user.id)
      {:ok, assign(socket, stats: stats)}
    else
      {:ok, socket}
    end
  end

  def handle_params(_params, _url, socket) do
    case socket.assigns.live_action do
      :preferences ->
        preferences = Acts.get_user_preferences(socket.assigns.current_user.id)
        form = to_form(preferences)
        {:noreply, assign(socket, form: form)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("save_preferences", %{"preferences" => params}, socket) do
    case Acts.update_user_preferences(socket.assigns.current_user, params) do
      {:ok, _preferences} ->
        {:noreply,
         socket
         |> put_flash(:info, "Preferences updated successfully")
         |> push_navigate(to: ~p"/profile")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end
end
