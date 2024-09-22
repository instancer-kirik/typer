defmodule Typer.Uploads do
  alias Typer.Blog.Post

  def get_image_by_filename(filename, post_slug) do
    case Typer.Blog.get_post!(post_slug) do
      %Post{images: images} when is_map(images) ->
        Map.get(images, filename)
      _ ->
        nil
    end
  end

  def store_images(post, uploaded_files) do
    images = Map.new(uploaded_files, fn {filename, path} ->
      {:ok, data} = File.read(path)
      {filename, data}
    end)

    Typer.Blog.update_post(post, %{images: images})
  end
end
