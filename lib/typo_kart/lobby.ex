defmodule TypoKart.Lobby do

  # Players:
  # 1. New player joins :lobby as game_id
  #
  # 2. When he clicks "join" on a game, game_id changes to something else.
  #    The player can also switch to a different game unless the game started.
  #
  # 3. Game starts, when all open slots for the game are taken or timer runs
  #    out. The players cannot switch game after that point.
  #
  # 4. After game is over, player returns to the lobby.
  # 5. (maybe later: player can choose his color in game)
  # 
  # player state transition --> lobby -> game -> locked-game -> lobby
  #
  # Games:
  #
  # 1. We also keep track of initializing/running/ended games.
  # 2. At any time, keep two new games in the pending pipeline.
  #
  # game state transition --> pending --> playing --> end
  #
  # LiveView/Web:
  # The view process displays players in the queue or playing, 
  # and games in the queue or in progress.
  #

  use GenServer

  @game_wait_time 30

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


  # Joining functions
  #
  # Join lobby
  def handle_call({:join_lobby, process_id, id}, _from, lobby) do
    player_id="player_" <> String.slice(id,0,3)
    player_detail=%{player: player_id, time: System.os_time(:second), id: id, game: :lobby, pos: nil}
    lobby=put_in(lobby, [:players, process_id], player_detail)
    {:reply, lobby, lobby}
  end


  # Join game
  # 1. Locked players cannot change game
  # 2. When three players join, invoke "begin_game" and "lock players"
  #
  def handle_call({:join_game, player_id, game_id, pos}, _from, lobby) do

    # Check that the player is not locked

    # Make player join game
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


    {:reply, lobby, lobby}
  end

  # Ending game
  # 1. Change status of game to "ended"
  # 2. Move all players to lobby
  #
  def handle_call({:game_ended, game_id}, lobby) do
    #
    # Unlock three player by moving them back to the lobby
    # unlock(player1)
    # unlock(player2)
    # unlock(player3)
    #
    # Change game status to ended
    #
    {:reply, lobby, lobby}
  end


  # Listing functions
  #
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

  def join_lobby(process_id, id) do
    GenServer.call(__MODULE__, {:join_lobby, process_id, id})
  end

  def join_game(player_id, game_id, pos) do
    GenServer.call(__MODULE__, {:join_game, player_id, game_id, pos})
  end

  def game_ended(game_id) do
   GenServer.call(__MODULE__, {:game_ended, game_id})
  end

  # Listing functions
  def list() do
    GenServer.call(__MODULE__, :list)
  end

  def list_players() do
    GenServer.call(__MODULE__, :list_players)
  end

  def list_games() do
    GenServer.call(__MODULE__, :list_games)
  end


  # Private functions for non-public action

  defp create_game(game_id) do
    # game_id=GameMaster.create_game()
    {:ok}
  end

  defp start_game(lobby, game_id) do
    # Call GameMaster
    # GameMaster.add_player(lobby.games[game_id].pos_1, "orange")
    # GameMaster.add_player(lobby.games[game_id].pos_2, "blue")
    # GameMaster.add_player(lobby.games[game_id].pos_1, "green")
    #
    # lock all those three players
    # lock(player1)
    # lock(player2)
    # lock(player3)
    #
    # Start game
    # GameMaster.start_game(game_id)
    #
    # Create another pending game
    # game_id=GameMaster.create_game()
    # lobby=lobby |> put_in([:games, game_id, :game], game_id)
    #
    {:ok}
  end

end
