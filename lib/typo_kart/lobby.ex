defmodule TypoKart.Lobby do

  # Players:
  # 1. New player joins and get game_id=0 (i.e. lobby)
  #
  # 2. When he clicks "join" on a game, game_id changes to something else.
  #    The player can also switch to a different game unless the game started.
  #
  # 3. Game starts, when all open slots for the game is taken. The players cannot 
  #    switch game after that point.
  #
  # 4. After game is over, player returns to lobby.
  #
  # 5. (maybe later: player can choose his color in game)
  # 
  # player state transition --> lobby -> game -> locked-game -> lobby
  #
  # Games:
  #
  # 1. We also keep track of initializing/running/ended games.
  #
  # 2. At any time, keep two new games in the pending pipeline.
  #
  # game state transition --> waiting --> play --> end
  #
  # LiveView/Web:
  # The view process displays players in the queue or playing, 
  # and games in the queue or in progress.
  #

  use GenServer

  def init(_init_arg) do
    {:ok, %{
       games: 
        %{"game_1" => %{:status => :wait, "pos_1" => nil, "pos_2" => nil, "pos_3" => nil}, 
          "game_2" => %{:status => :wait, "pos_1" => nil, "pos_2" => nil, "pos_3" => nil},
          "game_3" => %{:status => :wait, "pos_1" => nil, "pos_2" => nil, "pos_3" => nil}
        },
          players: %{}
      }
    }
  end

  def handle_cast({:join_lobby, process_id}, lobby) do
    id=UUID.uuid1()
    player_id="player_" <> String.slice(id,0,3)
    player_detail=%{player: player_id, time: System.os_time(:second), id: id, game: :lobby, pos: nil}
    lobby=put_in(lobby, [:players, process_id], player_detail)
    {:noreply, lobby}
  end


  # 1. Locked players cannot change game
  # 2. When three players join, invoke "begin_game" and "lock players"
  #
  def handle_call({:join_game, player_id, game_id, pos}, _from, lobby) do
    prev_game = lobby.players[player_id].game
    prev_pos  = lobby.players[player_id].pos 

    lobby =
      case prev_pos do
         nil -> lobby
         _   -> put_in(lobby, [:games, prev_game, prev_pos], nil)
    end

    lobby=lobby |>
          put_in([:players, player_id, :game], game_id) |>
          put_in([:players, player_id, :pos], pos) |>
          put_in([:games, game_id, pos], lobby.players[player_id].player)

    #IO.inspect lobby
    {:reply, lobby, lobby}
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

  def join_lobby(process_id) do
    GenServer.cast(__MODULE__, {:join_lobby, process_id})
  end

  def join_game(player_id, game_id, pos) do
    GenServer.call(__MODULE__, {:join_game, player_id, game_id, pos})
  end

  def list() do
    GenServer.call(__MODULE__, :list)
  end

  def list_players() do
    GenServer.call(__MODULE__, :list_players)
  end

  def list_games() do
    GenServer.call(__MODULE__, :list_games)
  end

  defp create_game(game_id) do
    {:ok}
  end

  defp start_game(game_id) do
    # {:ok} = Gamestate.start_link()
    {:ok}
  end

  def game_ended(game_id) do
   GenServer.cast(__MODULE__, {:game_ended, game_id})
  end

end

