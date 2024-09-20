defmodule Typer.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:slug, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :slug}
  schema "posts" do
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
    |> cast(attrs, [:title, :content, :description, :published_at])
    |> validate_required([:title, :content, :published_at])
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
    |> process_tags(attrs)
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        title = get_change(changeset, :title) || get_field(changeset, :title)
        if title, do: put_change(changeset, :slug, slugify(title)), else: changeset
      _ ->
        changeset
    end
  end

  defp slugify(str) when is_binary(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
    |> String.trim("-")
    |> (fn slug -> "#{slug}-#{Ecto.UUID.generate()}" end).()
  end
  defp slugify(_), do: nil

  defp process_tags(changeset, attrs) do
    tags = Map.get(attrs, "tags") || Map.get(attrs, :tags)
    case tags do
      nil -> changeset
      tags when is_binary(tags) ->
        put_change(changeset, :tags, split_tags(tags))
      tags when is_list(tags) ->
        put_change(changeset, :tags, Enum.map(tags, &String.trim/1))
      _ ->
        add_error(changeset, :tags, "must be a string or a list of strings")
    end
  end

  defp split_tags(tags) when is_binary(tags) do
    tags
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
