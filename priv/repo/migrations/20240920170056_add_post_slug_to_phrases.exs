defmodule Typer.Repo.Migrations.AddPostSlugToPhrases do
  use Ecto.Migration

  def change do
    alter table(:phrases) do
      add :post_slug, references(:posts, column: :slug, type: :string, on_delete: :nilify_all)
    end

    create index(:phrases, [:post_slug])
  end
end
