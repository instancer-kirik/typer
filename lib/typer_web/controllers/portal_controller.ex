defmodule TyperWeb.PortalController do
  use TyperWeb, :controller

  def index(conn, _params) do
    apps = [
      %{
        name: "Typer",
        description: "Practice typing with custom phrases",
        path: "/",
        icon: "⌨️"
      },
      %{
        name: "STREAM",
        description: "streaming",
        path: "/stream",
        icon: "🎵"
      },
      %{
        name: "Time Tracker Calendar",
        description: "Temporal charting with colors and such",
        path: "/time",
        icon: "⏱️"
      },
      %{
        name: "Blockchain Core",
        description: "Core blockchain functionality",
        path: "/blockchain",
        icon: "⛓️"
      },
      %{
        name: "Deepscape",
        description: "Workspace",
        path: "/deep",
        icon: "🧠"
      }
    ]

    render(conn, :index, apps: apps)
  end
end
