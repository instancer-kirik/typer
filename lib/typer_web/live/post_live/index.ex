defmodule TyperWeb.PostLive.Index do
  use TyperWeb, :live_view

  alias Typer.Blog
  alias Typer.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:posts, dom_id: &"post-#{&1.slug}")
     |> stream(:posts, Blog.list_posts())
     |> assign(:tags, Blog.list_tags())
     |> assign(:current_tag, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.inspect(socket.assigns.live_action, label: "Current live_action")
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Blog.get_post!(slug))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, %{"tag" => tag}) do
    socket
    |> assign(:page_title, "Listing Posts tagged with #{tag}")
    |> stream(:posts, Blog.list_posts_by_tag(tag), reset: true)
    |> assign(:current_tag, tag)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
    |> stream(:posts, Blog.list_posts(), reset: true)
    |> assign(:current_tag, nil)
  end

  @impl true
  def handle_info({TyperWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => slug}, socket) do
    post = Blog.get_post!(slug)
    {:ok, _} = Blog.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_event("filter_by_tag", %{"tag" => tag}, socket) do
    {:noreply, push_patch(socket, to: ~p"/posts/tag/#{tag}")}
  end

  @impl true
  def handle_event("clear_filter", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/posts")}
  end
end
