defmodule Typer.Blog do
  import Ecto.Query, warn: false
  alias Typer.Repo
  alias Typer.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:typer, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  @posts Enum.sort_by(@posts, & &1.published_at, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  def all_posts, do: @posts
  def all_tags, do: @tags

  def get_post_by_slug!(slug) do
    Enum.find(all_posts(), &(&1.slug == slug)) ||
    raise Ecto.NoResultsError, queryable: Post
  end

  def get_post_by_id!(id) do
    Enum.find(all_posts(), &(&1.id == id)) ||
      raise Ecto.NoResultsError, queryable: Post
  end

  def get_posts_by_tag!(tag) do
    case Enum.filter(all_posts(), &(tag in &1.tags)) do
      [] -> raise Ecto.NoResultsError, queryable: Post
      posts -> posts
    end
  end

  # Keep the existing database-related functions (list_posts, get_post!, create_post, etc.)
  # ...
end
