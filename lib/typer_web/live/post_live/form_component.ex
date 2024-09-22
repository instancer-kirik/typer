defmodule TyperWeb.PostLive.FormComponent do
  use TyperWeb, :live_component

  alias Typer.Blog
  alias Typer.Uploads

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 p-6 rounded-lg shadow-md text-gray-200">
      <.header class="text-gray-200">
        <%= @title %>
        <:subtitle class="text-gray-400">Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6 bg-gray-900 p-6 rounded-lg shadow-md text-gray-200"
      >
        <div class="space-y-4">
          <.input field={@form[:title]} type="text" label="Title" phx-debounce="blur" class="bg-gray-800 text-gray-200 border-gray-700" />
          <.input field={@form[:content]} type="textarea" label="Content" phx-debounce="blur" rows="10" class="bg-gray-800 text-gray-200 border-gray-700" />
          <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" class="bg-gray-800 text-gray-200 border-gray-700" />
          <.input field={@form[:tags]} type="text" label="Tags (comma-separated)" value={format_tags(@form[:tags].value)} phx-debounce="blur" class="bg-gray-800 text-gray-200 border-gray-700" />
          <datalist id="tag-suggestions">
            <%= for tag <- @existing_tags do %>
              <option value={tag} />
            <% end %>
          </datalist>
          <.input field={@form[:published_at]} type="date" label="Published at" phx-debounce="blur" class="bg-gray-800 text-gray-200 border-gray-700" />
        </div>

        <div class="mt-6">
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Upload Markdown File
          </label>
          <div class="flex items-center space-x-2">
            <button type="button" id="md-file-picker" phx-hook="FilePicker" class="px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2 focus:ring-offset-gray-800">
              Choose File
            </button>
            <span id="selected-file" class="text-sm text-gray-400"></span>
          </div>
        </div>

        <%= if @image_references && length(@image_references) > 0 do %>
          <div class="mt-6 bg-gray-800 p-4 rounded-md">
            <h3 class="text-lg font-medium text-gray-200 mb-4">Image References</h3>
            <div class="space-y-4">
              <%= for {ref, index} <- Enum.with_index(@image_references) do %>
                <div class="flex items-center space-x-4 bg-gray-700 p-3 rounded shadow-sm">
                  <span class="text-sm font-medium text-gray-300"><%= ref.name %></span>
                  <%= if Map.get(@uploaded_images, ref.name) do %>
                    <span class="text-green-400 text-sm">✓ Uploaded</span>
                  <% else %>
                    <div class="flex-1">
                      <.live_file_input upload={@uploads.image} class="text-gray-200" />
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <%= if Map.get(assigns, :preview_content) do %>
          <div class="mt-6">
            <h3 class="text-lg font-medium text-gray-200 mb-2">Preview</h3>
            <div class="mt-2 prose prose-invert prose-sm max-w-none bg-gray-800 p-4 rounded-md text-gray-200">
              <%= raw Earmark.as_html!(@preview_content) %>
            </div>
          </div>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving..." class="w-full bg-yellow-600 hover:bg-yellow-700 text-white">Save Post</.button>
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
    image_references = extract_image_references(post.content || "")

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:image_references, image_references)
     |> assign(:uploaded_images, %{})
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: 10)}
  end

  @impl true
  def update(%{file_selected: params} = assigns, socket) do
    {frontmatter, markdown_content} = parse_markdown(params["contents"])
    current_changeset = socket.assigns.form.source
    image_references = extract_image_references(markdown_content)

    updated_changeset = update_changeset_with_frontmatter(current_changeset, frontmatter, markdown_content)

    {:ok,
     socket
     |> assign(form: to_form(updated_changeset))
     |> assign(preview_content: markdown_content)
     |> assign(image_references: image_references)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: length(image_references))}
  end

  @impl true
  def handle_event("file-selected", %{"filename" => filename, "contents" => contents}, socket) do
    {frontmatter, markdown_content} = parse_markdown(contents)
    image_references = extract_image_references(markdown_content)

    changeset =
      %Blog.Post{}
      |> Blog.change_post(%{title: filename, content: markdown_content})
      |> update_changeset_with_frontmatter(frontmatter)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:preview_content, markdown_content)
     |> assign(:image_references, image_references)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: length(image_references))}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Blog.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        {entry.client_name, path}
      end)
      |> Map.new()

    save_post(socket, socket.assigns.action, post_params, uploaded_files)
  end

  defp save_post(socket, :new, post_params, uploaded_files) do
    case Blog.create_post(post_params, socket.assigns.current_user) do
      {:ok, post} ->
        {:ok, post} = Uploads.store_images(post, uploaded_files)
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_post(socket, :edit, post_params, uploaded_files) do
    case Blog.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        {:ok, post} = Uploads.store_images(post, uploaded_files)
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp replace_image_placeholders(content, uploaded_files) do
    Enum.reduce(uploaded_files, content, fn {original_name, url}, acc ->
      String.replace(acc, "![[#{original_name}]]", "![#{original_name}](#{url})")
    end)
  end

  defp parse_markdown(content) do
    case String.split(content, "---", parts: 3) do
      [_, frontmatter, markdown] ->
        {parse_frontmatter(frontmatter), String.trim(markdown)}
      _ ->
        {%{}, content}
    end
  end

  defp parse_frontmatter(frontmatter) do
    frontmatter
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, nil}, fn line, {acc, current_key} ->
      cond do
        String.starts_with?(line, "  ") && current_key ->
          # This is a continuation of a multi-line value
          {Map.update(acc, current_key, line, &(&1 <> "\n" <> line)), current_key}
        true ->
          case String.split(line, ":", parts: 2) do
            [key, value] ->
              {Map.put(acc, String.trim(key), String.trim(value)), nil}
            [key] ->
              # This might be the start of a multi-line value
              {acc, String.trim(key)}
            _ ->
              {acc, nil}
          end
      end
    end)
    |> elem(0)  # We only want the accumulated map, not the current_key
  end

  defp update_changeset_with_frontmatter(changeset, frontmatter, content) do
    changeset
    |> Ecto.Changeset.put_change(:title, Map.get(frontmatter, "title", changeset.changes[:title]))
    |> Ecto.Changeset.put_change(:description, Map.get(frontmatter, "description", changeset.changes[:description]))
    |> Ecto.Changeset.put_change(:tags, parse_tags(Map.get(frontmatter, "tags", changeset.changes[:tags])))
    |> Ecto.Changeset.put_change(:published_at, parse_date(Map.get(frontmatter, "published_at", changeset.changes[:published_at])))
    |> Ecto.Changeset.put_change(:content, content)
  end

  defp validate_published_at(:published_at, date) do
    case Date.compare(date, Date.utc_today()) do
      :gt -> []  # Future date is okay
      :eq -> []  # Today is okay
      :lt -> [published_at: "cannot be in the past"]
    end
  end

  defp parse_tags(tags) when is_binary(tags), do: String.split(tags, ",") |> Enum.map(&String.trim/1)
  defp parse_tags(tags) when is_list(tags), do: tags
  defp parse_tags(_), do: []

  defp parse_date(date) when is_binary(date) do
    case Date.from_iso8601(date) do
      {:ok, parsed_date} -> parsed_date
      _ -> nil
    end
  end
  defp parse_date(%Date{} = date), do: date
  defp parse_date(_), do: nil

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp extract_image_references(content) do
    ~r/!\[\[(.*?)\]\]/
    |> Regex.scan(content)
    |> Enum.map(fn [_, image_name] -> %{name: image_name, uploaded: false} end)
  end

  defp update_changeset_with_frontmatter(changeset, frontmatter) do
    changeset
    |> Ecto.Changeset.put_change(:title, Map.get(frontmatter, "title", changeset.changes[:title]))
    |> Ecto.Changeset.put_change(:description, Map.get(frontmatter, "description", changeset.changes[:description]))
    |> Ecto.Changeset.put_change(:tags, parse_tags(Map.get(frontmatter, "tags", changeset.changes[:tags])))
    |> Ecto.Changeset.put_change(:published_at, parse_date(Map.get(frontmatter, "published_at", changeset.changes[:published_at])))
  end
end
