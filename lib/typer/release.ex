defmodule Typer.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :typer

  def setup do
    load_app()

    for repo <- repos() do
      ensure_repo_created(repo)
      run_migrations_for(repo)
    end
  end

  def migrate do
    load_app()

    for repo <- repos() do
      run_migrations_for(repo)
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp ensure_repo_created(repo) do
    IO.puts("Creating repo #{inspect(repo)}")
    case repo.__adapter__.storage_up(repo.config) do
      :ok -> :ok
      {:error, :already_up} -> :ok
      {:error, term} -> raise "The database for #{inspect(repo)} couldn't be created: #{inspect(term)}"
    end
  end

  defp run_migrations_for(repo) do
    IO.puts("Running migrations for #{inspect(repo)}")
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  def seed do
    # Add your seeding logic here
    # For example:
    # Typer.Repo.insert!(%Typer.SomeSchema{...})
  end
end
