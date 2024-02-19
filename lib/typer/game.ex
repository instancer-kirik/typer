defmodule Typer.Game do
  import Ecto.Query, warn: false

  alias Typer.Repo
  alias Typer.Game.Phrase

  def list_phrases do
    query =
      from p in Phrase,
      select: p,
      order_by: [desc: :inserted_at],
      preload: [:user]

      Repo.all(query)
  end

  def get_phrase!(id) do
    Repo.get!(Phrase, id)
  end
  def save(phrase_params) do
    %Phrase{}
    |> Phrase.changeset(phrase_params)
    |> Repo.insert()
  end
end
