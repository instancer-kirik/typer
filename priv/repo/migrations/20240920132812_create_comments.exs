defmodule Typer.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text, null: false
      add :post_slug, references(:posts, column: :slug, type: :string), null: false
      add :user_id, references(:users, on_delete: :nilify_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:post_slug])
    create index(:comments, [:user_id])
  end
end
