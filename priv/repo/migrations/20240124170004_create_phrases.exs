defmodule Typer.Repo.Migrations.CreatePhrases do
  use Ecto.Migration

  def change do
    create table(:phrases) do
      add :text, :string

      timestamps(type: :utc_datetime)
    end
  end
end
