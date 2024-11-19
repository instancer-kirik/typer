defmodule Typer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TyperWeb.Telemetry,
      # Start the Ecto repository
      Typer.Repo,

      {DNSCluster, query: Application.get_env(:typer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Typer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Typer.Finch},
      # Start the Endpoint (http/https)
        # Add ConCache children with unique IDs
      Supervisor.child_spec({ConCache, [name: :user_progress, ttl_check_interval: false]}, id: :user_progress_cache),
      Supervisor.child_spec({ConCache, [name: :post_cache, ttl_check_interval: false]}, id: :post_cache),

      TyperWeb.Endpoint
      # Start a worker by calling: Typer.Worker.start_link(arg)
      # {Typer.Worker, arg},

       ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Typer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TyperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
