defmodule Typer.Game.Hash do
  use Ecto.Schema
  import Ecto.Changeset
  alias Typer.Accounts.User
  schema "hashes" do
    field :app_title, :string
    field :hash, :string
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hash, attrs) do
    hash
    |> cast(attrs, [:app_title, :hash, :user_id])
    |> validate_required([:app_title, :hash, :user_id])
  end
end
