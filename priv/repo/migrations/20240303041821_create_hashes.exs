defmodule Typer.Repo.Migrations.CreateHashes do
  use Ecto.Migration


  def change do
    create table(:hashes) do
      add :app_title, :string
      add :hash, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
  end
end
end
