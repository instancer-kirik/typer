defmodule TyperWeb.Router do

  use TyperWeb, :router

  import TyperWeb.UserAuth

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

  pipeline :ensure_confirmed_user do
    plug :require_confirmed_user
  end

  scope "/", TyperWeb do

    pipe_through :browser
    # Public routes
    get "/", PageController, :home
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


  # Other scopes may use custom stacks.
  # scope "/api", TyperWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:typer, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TyperWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TyperWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TyperWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
      live "/users/confirm/:token", UserConfirmationLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TyperWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TyperWeb.UserAuth, :ensure_authenticated}] do

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TyperWeb do
    pipe_through [:browser, :require_authenticated_user, :ensure_confirmed_user]

    # ... routes that require a confirmed user ...
  end
  scope "/", TyperWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    live "/home", HomeLive, :index
    live "/hash_slinging_hasher", HashSlingingHasherLive, :index
    live_session :current_user,
      on_mount: [{TyperWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
