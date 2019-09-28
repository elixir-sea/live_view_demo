defmodule TypoKartWeb.LobbyLive do
  use Phoenix.LiveView

  alias TypoKart.Lobby

  def render(assigns) do
    TypoKartWeb.LobbyView.render("index.html", assigns)
  end

  def mount(_session, socket) do

    if connected?(socket) do
      id=UUID.uuid1()
      %{games: games, players: players}=Lobby.join_lobby(self(), id)
      :timer.send_interval(  1_000, self(), :tick)
      {:ok, assign(socket, games: games, players: players) }
    else
      {:ok, assign(socket, games: %{}, players: %{}) }
    end
  end

  def handle_info(:tick, socket) do
    %{games: games, players: players}=Lobby.list()
    {:noreply, assign(socket, players: players, games: games) }
  end

  def handle_event( "join", %{"game" => game, "pos" => pos} , socket) do
    %{games: games, players: players}=Lobby.join_game(self(), game, pos)
    {:noreply, assign(socket, players: players, games: games) }
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

end
