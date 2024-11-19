defmodule Typer.Repo.Migrations.AlterPhraseTextSize do
  use Ecto.Migration

  def change do
    alter table(:phrases) do
      modify :text, :text
    end
  end
end
