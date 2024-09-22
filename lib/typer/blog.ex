defmodule Typer.Blog do
  import Ecto.Query, warn: false
  alias Typer.Repo
  alias Typer.Blog.Post
  alias Typer.Accounts.User
  alias Typer.Blog.Comment
  def list_posts do
    Repo.all(from p in Post, order_by: [desc: p.published_at])
  end

  def list_posts_by_tag(tag, sort_direction \\ :desc) do
    from(p in Post,
      where: ^tag in p.tags,
      order_by: [{^sort_direction, p.published_at}]
    )
    |> Repo.all()
  end

  def get_post!(slug) when is_binary(slug) do
    Repo.get_by!(Post, slug: slug)
  end

  def get_post!(id) when is_integer(id) do
    Repo.get!(Post, id)
  end

  def create_post(attrs \\ %{}, user) do
    attrs = process_image_uploads(attrs)

    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    attrs = process_image_uploads(attrs)

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

  def list_comments_for_post(%Post{} = post) do
    list_comments_for_post(post.slug)
  end

  def list_comments_for_post(post_slug) when is_binary(post_slug) do
    Repo.all(from c in Comment,
      where: c.post_slug == ^post_slug,
      order_by: [desc: c.inserted_at],
      preload: [user: [:username]]
    )
  end

  def create_comment(%Post{} = post, %User{} = user, attrs \\ %{}) do
    post
    |> Ecto.build_assoc(:comments)
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  defp process_image_uploads(attrs) do
    case Map.get(attrs, "image_uploads") do
      nil -> attrs
      uploads ->
        images = Enum.reduce(uploads, %{}, fn {name, upload}, acc ->
          case File.read(upload.path) do
            {:ok, binary} -> Map.put(acc, name, binary)
            _ -> acc
          end
        end)
        Map.put(attrs, "images", images)
    end
  end

  def list_posts(sort_direction \\ :desc) do
    from(p in Post, order_by: [{^sort_direction, p.published_at}])
    |> Repo.all()
  end


end
