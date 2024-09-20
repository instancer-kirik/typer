defmodule Typer.Blog do
  import Ecto.Query, warn: false
  alias Typer.Repo
  alias Typer.Blog.Post

  def list_posts do
    Repo.all(from p in Post, order_by: [desc: p.published_at])
  end

  def list_posts_by_tag(tag) do
    Repo.all(from p in Post,
      where: ^tag in p.tags,
      order_by: [desc: p.published_at])
  end

  def get_post!(slug) when is_binary(slug) do
    Repo.get_by!(Post, slug: slug)
  end

  def get_post!(id) when is_integer(id) do
    Repo.get!(Post, id)
  end

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def list_tags do
    Repo.all(from p in Post, select: fragment("DISTINCT unnest(?)", p.tags))
  end
end
