defmodule TyperWeb.BlogController do
  use TyperWeb, :controller

  alias Typer.Blog

  def index(conn, _params) do
    posts = Blog.all_posts()
    render(conn, :index, posts: posts)
  end

  def show(conn, %{"slug" => slug}) do
    post = Blog.get_post_by_slug!(slug)
    render(conn, :show, post: post)
  end
end
