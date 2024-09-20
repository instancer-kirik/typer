defmodule Typer.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}
  schema "posts" do
    field :slug, :string
    field :title, :string
    field :content, :string
    field :description, :string
    field :tags, {:array, :string}
    field :published_at, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:slug, :title, :content, :description, :tags, :published_at])
    |> validate_required([:slug, :title, :content, :published_at])
    |> unique_constraint(:slug)
  end

  # Add this function for NimblePublisher
  def build(filename, attrs, body) do
    [year, month, day] =
      Regex.run(~r/(\d{4})-(\d{2})-(\d{2})/, Path.basename(filename), capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    published_at = Date.from_erl!({year, month, day})

    struct!(__MODULE__, Map.merge(attrs, %{
      content: body,
      published_at: published_at
    }))
  end
end
