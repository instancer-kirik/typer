
defmodule Typer.Repo.Migrations.CreatePhraseAttempt do
  use Ecto.Migration

  def change do
    create table(:phrase_attempts) do
      add :wpm, :integer, null: false
      add :accuracy, :integer, null: false
      add :user_id, references(:users, on_delete: :nilify_all)
      add :phrase_id, references(:phrases, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:phrase_attempts, [:user_id])
    create index(:phrase_attempts, [:phrase_id])
  end
end
