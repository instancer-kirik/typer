defmodule TyperWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router
  import Plug.BasicAuth
  import Phoenix.Controller
  import Acts.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TyperWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admins_only do
    plug :basic_auth, username: "admin", password: "secret" # TODO: move to config
  end

  pipeline :authenticated do
    plug :require_authenticated_user
  end

  pipeline :ensure_confirmed_user do
    plug :require_confirmed_user
  end

  pipeline :redirect_auth do
    plug :redirect_if_user_is_authenticated
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

    live "/users/settings", Acts.UserSettingsLive, :edit
    live "/users/settings/confirm_email/:token", Acts.UserSettingsLive, :confirm_email
    live "/users/confirm/:token", Acts.UserConfirmationLive, :edit
    live "/users/confirm", Acts.UserConfirmationInstructionsLive, :new
    live "/home", HomeLive, :index
    live "/hash_slinging_hasher", HashSlingingHasherLive, :index
  end

  # Admin routes
  scope "/admin", TyperWeb do
    pipe_through [:browser, :authenticated, :admins_only]

    live "/dashboard", AdminDashboardLive
  end

  # Routes meant to be used within the Veix platform
  scope "/" do
    pipe_through [:browser, :authenticated]

    live "/", TyperWeb.DashboardLive
    live "/practice", TyperWeb.PracticeLive
    live "/multiplayer", TyperWeb.MultiplayerLive

    live "/rooms/:id", TyperWeb.RoomLive
    live "/stats", TyperWeb.StatsLive
  end

  # Routes when accessed directly (not through Veix)
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

    delete "/users/log_out", Acts.UserSessionController, :delete
  end

  scope "/", TyperWeb do
    pipe_through [:browser, :redirect_auth]

    live_session :redirect_auth,
      on_mount: [{Acts.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", Acts.UserRegistrationLive, :new
      live "/users/log_in", Acts.UserLoginLive, :new
      live "/users/reset_password", Acts.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", Acts.UserResetPasswordLive, :edit
    end

    post "/users/log_in", Acts.UserSessionController, :create
  end
end
