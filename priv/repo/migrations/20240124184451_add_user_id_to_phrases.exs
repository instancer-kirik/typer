defmodule Typer.Repo.Migrations.AddUserIdToPhrases do
  use Ecto.Migration


  def change do
    alter table(:phrases) do
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end
