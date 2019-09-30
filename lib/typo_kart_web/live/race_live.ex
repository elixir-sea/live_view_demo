defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView

  alias TypoKart.{
    GameMaster,
    ViewChar,
    Lobby
  }

  require Logger

  # See: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/keyCode
  @ignored_key_codes [
    # Backspace
    8,
    # Enter
    13,
    # Shift
    16,
    # Control
    17,
    # Alt
    18,
    # Caps Lock
    20,
    # Esc
    27,
    # PageUp
    33,
    # PageDown
    34,
    # End
    35,
    # Home
    36,
    # ArrowLeft
    37,
    # ArrowUp
    38,
    # ArrowRight
    39,
    # ArrowDown
    40,
    # Delete
    46,
    # Insert
    45,
    # Meta
    93
  ]

  def render(assigns) do
   case assigns do
    %{browser_incompatible: true} ->
      TypoKartWeb.RaceView.render("incompatible.html", assigns)

      _ ->
        TypoKartWeb.RaceView.render("index.html", assigns)
    end
  end

  def mount(_session, socket) do

    if connected?(socket) do
      player_id=UUID.uuid1()
      %{games: games, players: players}=Lobby.join_lobby(self(), player_id)
      :timer.send_interval(  1_000, self(), :tick)
      {:ok, assign(socket, games: games, players: players, id: player_id, lobby: true) }
    else
      {:ok, assign(socket, games: %{}, players: %{}, id: "", lobby: true) }
    end

  end

  def handle_info(:tick, socket) do
    players=socket.assigns.players
    player_id=socket.assigns.id
    case players[player_id].lock do
     true  -> { :noreply, socket}
     false -> %{games: games, players: players}=Lobby.list()
               {:noreply, assign(socket, players: players, games: games) }
    end
  end

  def handle_info({:start_game, game_id, player_index}, socket) do
    { :noreply,
      assign(
        socket,
        error_status: "",
        game: GameMaster.state() |> get_in([:games, game_id]),
        game_id: game_id,
        player_index: player_index,
        marker_rotation_offset: 90,
       marker_translate_offset_x: -30,
        marker_translate_offset_y: 30,
        view_chars: [],
        lobby: false
      ) }
  end


  def handle_event( "join", %{"game" => game_id, "pos" => pos} , socket) do
    player_id=socket.assigns.id
    %{games: games, players: players}=Lobby.join_game(player_id, game_id, pos)
    case players[player_id].lock do
      true  -> { :noreply, socket}
      false -> {:noreply, assign(socket, players: players, games: games) }
    end
  end

  def handle_event("key", %{"keyCode" => keyCode}, socket)
      when keyCode in @ignored_key_codes,
      do: {:noreply, socket}

  def handle_event(
        "key",
        %{"key" => key},
        %{
          assigns: %{
            game_id: game_id,
            player_index: player_index
          }
        } = socket
      ) do
    case GameMaster.advance(game_id, player_index, String.to_charlist(key) |> hd()) do
      {:ok, game} ->
        {:noreply,
         assign(socket,
           error_status: "",
           game: game
         )}

      {:error, _} ->
        {:noreply, assign(socket, error_status: "error")}
    end
  end

  def handle_event("key", _, socket),
    do: {:noreply, assign(socket, error_status: "error")}

  def handle_event("bail_out_browser_incompatible", _, socket),
    do: {:noreply, assign(socket, browser_incompatible: true)}

  def handle_event(
        "load_char_data",
        paths,
        socket
      )
      when is_list(paths) do
    view_chars =
      paths
      |> Enum.map(fn path ->
        path
        |> Enum.map(fn char ->
          %ViewChar{
            x: get_in(char, ["point", "x"]),
            y: get_in(char, ["point", "y"]),
            rotation: get_in(char, ["rotation"])
          }
        end)
      end)

    {:noreply, assign(socket, view_chars: view_chars)}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

end
