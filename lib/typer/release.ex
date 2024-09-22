defmodule Typer.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :typer

  def setup do
    load_app()

    for repo <- repos() do
      IO.puts("Setting up repo: #{inspect(repo)}")
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
    IO.puts("Ensuring repo #{inspect(repo)} is created...")
    case repo.__adapter__.storage_up(repo.config) do
      :ok -> IO.puts("The database for #{inspect(repo)} has been created")
      {:error, :already_up} -> IO.puts("The database for #{inspect(repo)} has already been created")
      {:error, term} ->
        IO.puts("The database for #{inspect(repo)} couldn't be created: #{inspect(term)}")
        raise "Error creating the database"
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
    Application.ensure_all_started(:ssl)
  end

  def seed do
    # Add your seeding logic here
    # For example:
    # Typer.Repo.insert!(%Typer.SomeSchema{...})
  end
end
