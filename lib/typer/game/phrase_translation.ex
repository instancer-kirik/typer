defmodule Typer.Game.PhraseTranslation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "phrase_translations" do
    field :text, :string
    field :language_code, :string
    field :phrase_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(phrase_translation, attrs) do
    phrase_translation
    |> cast(attrs, [:text, :language_code])
    |> validate_required([:text, :language_code])
  end
end
