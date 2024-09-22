defmodule Typer.Repo.Migrations.UpdatePostsTable do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :nilify_all)
    end

    create index(:posts, [:user_id])
  end
end
