defmodule Typer.Repo do
  use Ecto.Repo,
    otp_app: :typer,
    adapter: Ecto.Adapters.Postgres
end
