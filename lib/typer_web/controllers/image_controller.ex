defmodule TyperWeb.ImageController do
  use TyperWeb, :controller

  alias Typer.Blog

  def show(conn, %{"slug" => slug, "name" => name}) do
    post = Blog.get_post!(slug)
    case post.images[name] do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("Image not found")
      image_data ->
        conn
        |> put_resp_content_type("image/png") # Adjust content type as needed
        |> send_resp(200, image_data)
    end
  end
end
