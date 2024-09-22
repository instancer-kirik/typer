defmodule TyperWeb.PostLive.Show do
  use TyperWeb, :live_view

  alias Typer.Blog
  alias Typer.Blog.Comment
  alias Typer.Accounts.User
  alias Typer.Repo
  alias Typer.Game
  alias Typer.Accounts
  alias Typer.Uploads

  @impl true
  def mount(_params, session, socket) do
    current_user = get_current_user(session)
    {:ok, assign(socket, current_user: current_user, show_sidebar: true)}
  end

  defp get_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         user when not is_nil(user) <- Accounts.get_user_by_session_token(user_token) do
      user
    else
      _ -> nil
    end
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    post = Blog.get_post!(slug) |> Typer.Repo.preload([:user, :phrase])
    processed_content = process_obsidian_images(post.content, post)
    comments = Blog.list_comments_for_post(post)
    changeset = Blog.change_comment(%Comment{})

    {phrase, leaderboard} = case post.phrase do
      nil ->
        {:ok, phrase} = Game.get_or_create_phrase_for_post(post)
        {phrase, Game.get_leaderboard_for_phrase(phrase.id)}
      phrase ->
        {phrase, Game.get_leaderboard_for_phrase(phrase.id)}
    end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, %{post | content: processed_content})
     |> assign(:comments, comments)
     |> assign(:comment_form, to_form(changeset))
     |> assign(:phrase, phrase)
     |> assign(:leaderboard, leaderboard)
     |> assign(:show_leaderboard, false)
     |> assign_existing_tags(socket.assigns.live_action)}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"

  defp assign_existing_tags(socket, :edit) do
    assign(socket, :existing_tags, Blog.list_tags())
  end
  defp assign_existing_tags(socket, _), do: assign(socket, :existing_tags, [])

  @impl true
  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    case create_comment(socket.assigns.post, socket.assigns.current_user, comment_params) do
      {:ok, _comment} ->
        updated_comments = Blog.list_comments_for_post(socket.assigns.post)
        {:noreply,
         socket
         |> put_flash(:info, "Comment added successfully")
         |> assign(:comments, updated_comments)
         |> assign(:comment_form, to_form(Blog.change_comment(%Comment{})))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :comment_form, to_form(changeset))}
    end
  end

  defp create_comment(_post, nil, _comment_params) do
    {:error, :not_authenticated}
  end

  defp create_comment(post, user, comment_params) do
    Blog.create_comment(post, user, comment_params)
  end

  @impl true
  def handle_event("file-selected", params, socket) do
    send_update(TyperWeb.PostLive.FormComponent, id: socket.assigns.post.id, file_selected: params)
    {:noreply, socket}
  end

  defp comment_author(%{user: %{username: username}}), do: username
  defp comment_author(_), do: "Anonymous"

  @impl true
  def handle_event("toggle_leaderboard", _, socket) do
    {:noreply, assign(socket, :show_leaderboard, !socket.assigns.show_leaderboard)}
  end

  @impl true
  def handle_event("toggle_sidebar", _, socket) do
    {:noreply, socket |> assign(show_sidebar: !socket.assigns.show_sidebar) |> push_event("toggle_sidebar", %{})}
  end

  defp process_obsidian_images(content, post) do
    Regex.replace(~r/!\[\[(.*?)\]\]/, content, fn _, filename ->
      case Uploads.get_image_by_filename(filename, post.slug) do
        nil -> "![#{filename}](image not found)"
        _image_data -> "![#{filename}](/posts/#{post.slug}/images/#{filename})"
      end
    end)
  end
end
