defmodule Typer.Repo.Migrations.CreatePhraseTranslations do
  use Ecto.Migration

  def change do
    create table(:phrase_translations) do
      add :text, :string
      add :language_code, :string
      add :phrase_id, references(:phrases, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:phrase_translations, [:phrase_id])
  end
end
