defmodule TyperWeb.PostLive.Index do
  use TyperWeb, :live_view

  alias Typer.Blog
  alias Typer.Blog.Post

  @impl true
  def mount(_params, session, socket) do
    current_user = get_current_user(session)
    IO.puts("Initial sort direction: desc")
    {:ok,
     socket
     |> stream_configure(:posts, dom_id: &"post-#{&1.slug}")
     |> assign(:existing_tags, Blog.list_tags())
     |> assign(:current_tag, nil)
     |> assign(:current_user, current_user)
     |> assign(:can_create_post, can_create_post?(current_user))
     |> assign(:sort_direction, :desc)}
  end

  @impl true
  def handle_params(params, _url, socket) do
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

  defp apply_action(socket, :index, %{"tag" => tag} = params) do
    sort_direction = String.to_existing_atom(params["sort"] || "desc")
    socket
    |> assign(:page_title, "Listing Posts tagged with #{tag}")
    |> assign(:current_tag, tag)
    |> assign(:sort_direction, sort_direction)
    |> stream(:posts, fetch_posts(tag, sort_direction), reset: true)
  end

  defp apply_action(socket, :index, params) do
    sort_direction = String.to_existing_atom(params["sort"] || "desc")
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
    |> assign(:current_tag, nil)
    |> assign(:sort_direction, sort_direction)
    |> stream(:posts, fetch_posts(nil, sort_direction), reset: true)
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
    IO.puts("Filtering by tag: #{tag}")
    sort_direction = socket.assigns.sort_direction
    params = %{"tag" => tag, "sort" => Atom.to_string(sort_direction)}

    socket = socket
    |> assign(:current_tag, tag)
    |> stream(:posts, fetch_posts(tag, sort_direction), reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_filter", _, socket) do
    params = %{"sort" => Atom.to_string(socket.assigns.sort_direction)}
    {:noreply, push_patch(socket, to: ~p"/posts?#{params}")}

  end

  @impl true
  def handle_event("file-selected", params, socket) do
    send_update(TyperWeb.PostLive.FormComponent, id: :new, file_selected: params)
    {:noreply, socket}

  end

  @impl true
  def handle_event("sort", params, socket) do
    IO.inspect(params, label: "Sort event params")
    sort = params["sort"]
    IO.puts("Sorting with direction: #{sort}")
    sort_direction = String.to_existing_atom(sort)
    params = if socket.assigns.current_tag, do: %{"tag" => socket.assigns.current_tag}, else: %{}
    params = Map.put(params, "sort", sort)

    socket = socket
    |> assign(:sort_direction, sort_direction)
    |> stream(:posts, fetch_posts(socket.assigns.current_tag, sort_direction), reset: true)

    {:noreply, socket}  # Remove push_patch here
  end

  defp fetch_posts(nil, sort_direction) do
    Blog.list_posts(sort_direction)
  end

  defp fetch_posts("", sort_direction) do
    Blog.list_posts(sort_direction)
  end

  defp fetch_posts(tag, sort_direction) when tag in [nil, ""] do
    Blog.list_posts(sort_direction)
  end

  defp fetch_posts(tag, sort_direction) do
    Blog.list_posts_by_tag(tag, sort_direction)
  end

  defp get_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         user when not is_nil(user) <- Typer.Acts.get_user_by_session_token(user_token) do
      user
    else
      _ -> nil
    end
  end

  defp can_create_post?(nil), do: false
  defp can_create_post?(%{is_admin: true}), do: true
  defp can_create_post?(_), do: false

end
