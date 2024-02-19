defmodule Typer.Game.Phrase do
  use Ecto.Schema
  import Ecto.Changeset
  alias Typer.Accounts.User
  schema "phrases" do
    field :text, :string
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(phrase, attrs) do
    phrase
    |> cast(attrs, [:text, :user_id])
    |> validate_required([:text, :user_id])
  end
end
