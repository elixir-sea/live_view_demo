defmodule TypoKart.Lobby do

  # Players:
  # 1. New players join and get game_id=0, when they are in the lobby.
  # 2. When they join a game, game_id changes to something else.
  #    The players can switch to different proposed games.
  # 3. When >X players join a game, the game starts. The players 
  #    cannot switch game after that point.
  # 4. (Later: add player color selection)
  #
  # Games:
  # 1. We also keep track of running/initializing games.
  # 2. At any time, keep three new games in the pipeline.
  #
  # View:
  # The view process displays players in the queue or playing, 
  # and games in the queue or in progress.
  #

  use GenServer

  def init(_init_arg) do
    {:ok, %{games: %{}, players: %{}}  }
  end

  def handle_cast({:join_lobby, player_id}, lobby) do
    lobby=put_in(lobby, [:players, player_id], 0)
    {:noreply, lobby}
  end


  # 1. Locked players cannot change game
  # 2. When three players join, invoke "begin_game" and "lock players"
  #
  def handle_cast({:join_game, player_id, game_id}, lobby) do
    lobby=put_in(lobby, [:players, player_id], game_id)
    {:noreply, lobby}
  end


  # 1. Change status of game to "ended"
  # 2. Move all players to lobby
  #
  def handle_cast({:game_ended, game_id}, lobby) do
    {:noreply, lobby}
  end

  def handle_call(:list, _from, lobby) do
    {:reply, lobby, lobby}
  end

  def handle_call(:list_players, _from, lobby) do
    {:reply, lobby.players, lobby}
  end

  def handle_call(:list_games, _from, lobby) do
    {:reply, lobby.games, lobby}
  end


  # Public API
  def start_link(_init \\ nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def join_lobby(pid, player_id) do
    GenServer.cast(pid, {:join_lobby, player_id})
  end

  def join_game(pid, player_id, game_id) do
    GenServer.cast(pid, {:join_game, player_id, game_id})
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  def list_players(pid) do
    GenServer.call(pid, :list_players)
  end

  def list_games(pid) do
    GenServer.call(pid, :list_games)
  end

  defp create_game(game_id) do
    {:ok}
  end

  defp start_game(game_id) do
    # {:ok, pid} = Gamestate.start_link()
    {:ok}
  end

  def game_ended(pid, game_id) do
   GenServer.cast(pid, {:game_ended, game_id})
  end

end

