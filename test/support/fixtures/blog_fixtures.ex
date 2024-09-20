defmodule Typer.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Typer.Blog` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        published_at: ~D[2024-09-17],
        title: "some title"
      })
      |> Typer.Blog.create_post()

    post
  end
end
