defmodule Typer.Repo.Migrations.AddImagesToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :images, :map
    end
  end
end
