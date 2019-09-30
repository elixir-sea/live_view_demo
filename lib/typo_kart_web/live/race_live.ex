defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView

  alias TypoKart.{
    Game,
    GameMaster,
    Util,
    ViewChar
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

  @game_update_rate_limit_ms 250
  @game_update_auto_interval_ms 1000

  def render(assigns) do
    case assigns do
      %{browser_incompatible: true} ->
        TypoKartWeb.RaceView.render("incompatible.html", assigns)

      %{game: %Game{state: :ended}} ->
        TypoKartWeb.RaceView.render("game_end.html", assigns)

      %{game: %Game{}} ->
        TypoKartWeb.RaceView.render("index.html", assigns)

      _ ->
        TypoKartWeb.RaceView.render("error.html", assigns)
    end
  end

  def mount(%{game_id: game_id, player_index: player_index}, socket) do
    # Reminder: mount() is called twice, once for the static HTML mount,
    # and again when the websocket is mounted.
    # We can test whether it's the latter case with connected?(socket)

    if connected?(socket), do: :timer.send_interval(@game_update_auto_interval_ms, self(), :update_game)

    with %Game{} = game <- game_with_current_player_view(game_id, player_index) do
      {
        :ok,
        assign(
          socket,
          error_status: "",
          game: game,
          game_id: game_id,
          player_index: player_index,
          marker_rotation_offset: 90,
          marker_translate_offset_x: -30,
          marker_translate_offset_y: 30,
          last_game_update: Util.now_unix(:millisecond),
          view_chars: []
        )
      }
    else
      _bad ->
        {:ok, socket}
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
           game: game,
           last_game_update: Util.now_unix(:millisecond)
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

  def handle_info(:end_game, %{
          assigns: %{
            game_id: game_id
          }} = socket
  ) do
    {:noreply, assign(socket, game: GameMaster.state() |> get_in([:games, game_id]))}
  end

  def handle_info(:update_game, %{
          assigns: %{
            game_id: game_id
          }} = socket
  ) do
    if should_update_game?(socket) do
      {:noreply, assign(socket, last_game_update: Util.now_unix(:millisecond), game: GameMaster.state() |> get_in([:games, game_id]))}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_, _, socket), do: {:noreply, socket}

  defp game_with_current_player_view(game_id, player_index) when is_binary(game_id) and is_integer(player_index) do
    with {:ok, %Game{} = game} <- GameMaster.register_player_view(game_id, player_index, self()) do
      game
    else
      bad ->
        bad
    end
  end

  defp should_update_game?(%{assigns: %{last_game_update: last_game_update}}) do
    (Util.now_unix(:millisecond) - last_game_update) >= @game_update_rate_limit_ms
  end
end
