defmodule Typer.Game do
  import Ecto.Query, warn: false

  alias Typer.Repo
  alias Typer.Game.Phrase
  alias Typer.Game.PhraseAttempt
  alias Typer.Blog.Post

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
    |> Repo.preload(:post)
  end
  def get_phrase(id) do
    Repo.get(Phrase, id)
  end

  def delete_phrase(id) do
    phrase = Repo.get!(Phrase, id)
    Repo.delete(phrase)
  end

  def save(phrase_params) do
    %Phrase{}
    |> Phrase.changeset(phrase_params)
    |> Repo.insert()
  end

  def create_phrase_from_post(%Post{} = post) do
    %Phrase{}
    |> Phrase.changeset(%{text: post.content, user_id: post.user_id, post_slug: post.slug})
    |> Repo.insert()
  end

  def get_or_create_phrase_for_post(%Post{} = post) do
    case Repo.get_by(Phrase, post_slug: post.slug) do
      nil -> create_phrase_from_post(post)
      phrase -> {:ok, phrase}
    end
  end

  def create_phrase_attempt(attrs \\ %{}) do
    IO.inspect(attrs, label: "Creating phrase attempt with attrs")
    result = %PhraseAttempt{}
    |> PhraseAttempt.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, attempt} ->
        IO.inspect(attempt, label: "Created attempt")
        {:ok, attempt}
      {:error, changeset} ->
        IO.inspect(changeset, label: "Failed to create attempt")
        {:error, changeset}
    end
  end

  def get_leaderboard_for_phrase(phrase_id) do
    one_day_ago = DateTime.utc_now() |> DateTime.add(-1, :day)

    query = from pa in PhraseAttempt,
      where: pa.phrase_id == ^phrase_id and pa.inserted_at >= ^one_day_ago,
      order_by: [desc: pa.wpm],
      limit: 10,
      preload: [:user, phrase: :post]

    results = Repo.all(query)

    IO.inspect(results, label: "Leaderboard results for phrase_id #{phrase_id}")

    results
  end

  def calculate_wpm(text_length, elapsed_time_seconds) do
    words = text_length / 5  # Assuming average word length of 5 characters
    minutes = elapsed_time_seconds / 60
    trunc(words / minutes)
  end

  def calculate_accuracy(text, user_input) do
    correct_chars = Enum.zip(String.graphemes(text), String.graphemes(user_input))
                    |> Enum.count(fn {a, b} -> a == b end)
    total_chars = String.length(text)
    trunc((correct_chars / total_chars) * 100)
  end
end
