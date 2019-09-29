defmodule TypoKart.Lobby do

  # HERE ARE THE SOURCES OF BUGS -
  #	I did not implement timer-led game start, but when I
  #     do, I need to make sure the "nil" players are not sent to GameMaster.
  #
  #
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

  alias TypoKart.{
    GameMaster,
    Player,
    Courses,
    Game
  }

  @game_wait_time 30

  def init(_init_arg) do
	id=GameMaster.new_game()
    {:ok, %{
          games: 
            %{id => %{:status => :pending, :gamemaster_id => nil, :pos_1 => nil, :pos_2 => nil}
          },
          players: %{}
      }
    }
  end

  # Joining functions
  #
  # Join lobby
  def handle_call({:join_lobby, process_id, id}, _from, lobby) do
    player_detail=%{player: id, time: System.os_time(:second), process_id: process_id, game: :lobby, pos: nil, lock: false}
    lobby=put_in(lobby, [:players, id], player_detail)
    {:reply, lobby, lobby}
  end


  # Join game
  # 1. Locked players cannot change game
  # 2. When three players join, invoke "begin_game" and "lock players"
  #
  def handle_call({:join_game, player_id, game_id, pos}, _from, lobby) do

    # Check that the player is not locked
    case lobby.players[player_id].lock do
      true -> {:reply, lobby, lobby}
      _ ->

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

        lobby =
           cond do
             (lobby.games[game_id].pos_1 != nil && lobby.games[game_id].pos_2 != nil )  -> lobby |> start_game(game_id)
             true -> lobby
           end

        {:reply, lobby, lobby}
     end
  end

  # Ending game
  # 1. Change status of game to "ended"
  # 2. Move all players to lobby
  #
  def handle_call({:game_ended, game_id}, lobby) do

    player1=lobby.games[game_id].pos_1
    player2=lobby.games[game_id].pos_2

    lobby = lobby |>
         put_in([:players, player1, :lock], false) |>
         put_in([:players, player2, :lock], false) |>
         put_in([:games, game_id, :status], :ended) 
            
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
    GenServer.call(__MODULE__, {:join_game, player_id, game_id, String.to_existing_atom(pos)})
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


  defp start_game(lobby, game_id) do

    #
    # Add players in GameMaster
    #
     player1=lobby.games[game_id].pos_1
     player2=lobby.games[game_id].pos_2
     pid1=lobby.players[player1].process_id
     pid2=lobby.players[player2].process_id

   {:ok, course} = Courses.load("course2")

        gamemaster_id=GameMaster.new_game(%Game{
          players: [
            %Player{
              color: "orange",
              label: player1
            },
            %Player{
              color: "blue",
              label: player2
            }
          ],
          course: course
        })

    # Lock players and game
    lobby = lobby |>
         put_in([:games, game_id, :gamemaster_id], gamemaster_id) |>
         put_in([:players, player1, :lock], true) |>
         put_in([:players, player2, :lock], true) |>
         put_in([:games, game_id, :status], :playing) 

    # Send messages to start game
    send pid1, {:start_game, gamemaster_id, 0}
    send pid2, {:start_game, gamemaster_id, 1}
    IO.inspect "game started"
            
    #
    # Create another pending game
    #
    game_id=UUID.uuid1()
    game_details=%{:status => :pending, :gamemaster_id => nil, :pos_1 => nil, :pos_2 => nil}
    lobby=lobby |> put_in([:games, game_id], game_details)

    lobby
  end

end

