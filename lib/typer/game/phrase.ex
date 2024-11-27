defmodule Typer.Game.Phrase do
  use Ecto.Schema
  import Ecto.Changeset
  alias Typer.Acts.User
  alias Typer.Blog.Post

  schema "phrases" do
    field :text, :string
    belongs_to :user, User
    belongs_to :post, Post, foreign_key: :post_slug, references: :slug, type: :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(phrase, attrs) do
    phrase
    |> cast(attrs, [:text, :user_id, :post_slug])
    |> validate_required([:text])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:post_slug)
  end
end
