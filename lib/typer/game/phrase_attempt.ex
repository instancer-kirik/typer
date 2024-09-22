# lib/typer/game/phrase_attempt.ex

defmodule Typer.Game.PhraseAttempt do
  use Ecto.Schema
  import Ecto.Changeset
  alias Typer.Accounts.User
  alias Typer.Game.Phrase

  schema "phrase_attempts" do
    field :wpm, :integer
    field :accuracy, :integer
    belongs_to :user, User
    belongs_to :phrase, Phrase

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(phrase_attempt, attrs) do
    phrase_attempt
    |> cast(attrs, [:wpm, :accuracy, :user_id, :phrase_id])
    |> validate_required([:wpm, :accuracy, :user_id, :phrase_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:phrase_id)
  end
end
