defmodule Typer.Repo.Migrations.UpdateHashesAllowNullUserId do
  use Ecto.Migration

  def change do
    alter table(:hashes) do
      modify :user_id, :integer, null: true
    end
  end
end
