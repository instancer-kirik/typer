defmodule Typer.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :slug, :string, primary_key: true
      add :title, :string, null: false
      add :content, :text, null: false
      add :description, :text
      add :tags, {:array, :string}
      add :published_at, :date, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:posts, [:slug])
  end
end
