defmodule TypoKartWeb.LobbyLive do
  use Phoenix.LiveView

  alias TypoKart.Lobby

  def render(assigns) do
    TypoKartWeb.LobbyView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket) do
        Lobby.join_lobby(self())
        :timer.send_interval(  1_000, self(), :tick)
    end
    %{games: games, players: players}=Lobby.list()
    {:ok, assign(socket, players: players, games: games) }
  end

  def handle_info(:tick, socket) do
    %{games: games, players: players}=Lobby.list()
    {:noreply, assign(socket, players: players, games: games) }
  end


  def handle_event( "join", %{"game" => game, "pos" => pos} , socket) do
    %{games: games, players: players}=Lobby.join_game(self(), game, pos)
    #IO.inspect "main game"
    #IO.inspect games
    #IO.inspect "main game"
    {:noreply, assign(socket, players: players, games: games) }
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

end
