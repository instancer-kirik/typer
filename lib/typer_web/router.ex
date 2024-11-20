defmodule TyperWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router
  import Plug.BasicAuth
  import Phoenix.Controller
  import Accounts.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TyperWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Accounts.FetchCurrentUserPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admins_only do
    plug :basic_auth, username: "admin", password: "secret" # TODO: move to config
  end

  pipeline :authenticated do
    plug Accounts.EnsureAuthenticatedPlug
  end

  pipeline :ensure_confirmed_user do
    plug Accounts.EnsureConfirmedUserPlug
  end

  scope "/", TyperWeb do
    pipe_through :browser

    # Public routes
    get "/", PageController, :home
    get "/portal", PortalController, :index
    live "/phrases/:id", PhraseLive, :show, as: :phrase

    post "/set_custom_phrase", SessionController, :set_custom_phrase
    get "/toggle_dark_mode", SessionController, :toggle_dark_mode
    post "/add-hash", SessionController, :add_hash
    get "/update-cookies", SessionController, :update_cookies
    get "/toggle_show_elixir", SessionController, :toggle_elixir

    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Index, :new
    live "/posts/tag/:tag", PostLive.Index, :index
    live "/posts/:slug", PostLive.Show, :show
    live "/posts/:slug/edit", PostLive.Show, :edit
    get "/posts/:slug/images/:filename", ImageController, :show
  end

  # Authenticated routes
  scope "/", TyperWeb do
    pipe_through [:browser, :authenticated, :ensure_confirmed_user]

    live "/users/settings", UserSettingsLive, :edit
    live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    live "/users/confirm/:token", UserConfirmationLive, :edit
    live "/users/confirm", UserConfirmationInstructionsLive, :new
    live "/home", HomeLive, :index
    live "/hash_slinging_hasher", HashSlingingHasherLive, :index
  end

  # Admin routes
  scope "/admin", TyperWeb do
    pipe_through [:browser, :authenticated, :admins_only]

    live "/dashboard", AdminDashboardLive
  end

  # Routes meant to be used within the Ves platform
  scope "/" do
    pipe_through [:browser, :authenticated]

    live "/", TyperWeb.DashboardLive
    live "/practice", TyperWeb.PracticeLive
    live "/multiplayer", TyperWeb.MultiplayerLive

    live "/rooms/:id", TyperWeb.RoomLive
    live "/stats", TyperWeb.StatsLive
  end

  # Routes when accessed directly (not through Ves)
  scope "/typer" do
    pipe_through [:browser, :authenticated]

    live "/", TyperWeb.DashboardLive
    live "/practice", TyperWeb.PracticeLive
    live "/multiplayer", TyperWeb.MultiplayerLive

    live "/rooms/:id", TyperWeb.RoomLive
    live "/stats", TyperWeb.StatsLive
  end

  # Enable LiveDashboard in development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :authenticated, :admins_only]
      live_dashboard "/dashboard", metrics: TyperWeb.Telemetry
    end
  end

  scope "/", TyperWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end

  scope "/", TyperWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TyperWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end
end
