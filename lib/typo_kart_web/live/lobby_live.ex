defmodule TypoKartWeb.LobbyLive do
  use Phoenix.LiveView

  def render(assigns) do
    TypoKartWeb.LobbyView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    # Reminder: mount() is called twice, once for the static HTML mount,
    # and again when the websocket is mounted.
    # We can test whether it's the latter case with:
    #
    # connected?(socket)
    {:ok, socket}
  end

end
