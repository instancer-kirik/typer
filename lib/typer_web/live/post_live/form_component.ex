defmodule TyperWeb.PostLive.FormComponent do
  use TyperWeb, :live_component

  alias Typer.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:content]} type="textarea" label="Content" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:tags]} type="text" label="Tags (comma-separated)" value={format_tags(@form[:tags].value)} />
        <datalist id="tag-suggestions">
          <%= for tag <- @existing_tags do %>
            <option value={tag} />
          <% end %>
        </datalist>
        <.input field={@form[:published_at]} type="date" label="Published at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp format_tags(tags) when is_list(tags), do: Enum.join(tags, ", ")
  defp format_tags(tags) when is_binary(tags), do: tags
  defp format_tags(_), do: ""

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Blog.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:existing_tags, Blog.list_tags())
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    IO.inspect(post_params, label: "Received post_params")
    changeset =
      socket.assigns.post
      |> Blog.change_post(post_params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset, label: "Changeset after validation")
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  defp save_post(socket, :edit, post_params) do
    case Blog.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Blog.create_post(post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
