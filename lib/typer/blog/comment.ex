defmodule Typer.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    belongs_to :post, Typer.Blog.Post, foreign_key: :post_slug, references: :slug, type: :string
    belongs_to :user, Typer.Acts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :post_slug, :user_id])
    |> validate_required([:content, :post_slug, :user_id])
    |> validate_length(:content, min: 1, max: 1000)
  end
end
