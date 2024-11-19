# lib/typer_web/live/leaderboard_live.ex

defmodule TyperWeb.LeaderboardLive do
  use TyperWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="leaderboard">
      <%= if Enum.empty?(@leaderboard) do %>
        <p class="text-center py-4">No attempts recorded yet. Be the first!</p>
      <% else %>
        <table class="w-full text-sm">
          <thead>
            <tr class="bg-gray-200">
              <th class="p-2 text-left">Rank</th>
              <th class="p-2 text-left">User</th>
              <th class="p-2 text-right">WPM</th>
              <th class="p-2 text-right">Accuracy</th>
              <%= if @show_post_title do %>
                <th class="p-2 text-left">Post</th>
              <% end %>
            </tr>
          </thead>
          <tbody>
            <%= for {entry, index} <- Enum.with_index(@leaderboard, 1) do %>
              <tr class="border-t border-gray-300">
                <td class="p-2"><%= index %></td>
                <td class="p-2"><%= entry.user.username %></td>
                <td class="p-2 text-right"><%= entry.wpm %></td>
                <td class="p-2 text-right"><%= entry.accuracy %>%</td>
                <%= if @show_post_title do %>
                  <td class="p-2">
                    <%= if entry.phrase.post, do: entry.phrase.post.title, else: "N/A" %>
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      <% end %>
    </div>
    """
  end
end
