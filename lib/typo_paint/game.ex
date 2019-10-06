defmodule TypoPaint.Game do
  alias TypoPaint.{
    Course,
    Player
  }

  @type game_state() :: :pending | :running | :ended
  defstruct state: :pending,
            end_time: DateTime.from_unix!(0),
            players: [],
            course: %Course{},
            game_duration_seconds: 0,
            timer: nil,
            # two dimensional array:
            #   - level-1: corresponds to the list of paths in the course
            #   - level-2: corresponds to each char in that path
            #
            # The value in the slot will be the player_index who owns that char,
            # or nil if it's unowned.
            char_ownership: []

  @type t :: %__MODULE__{
          state: game_state(),
          end_time: DateTime.t(),
          players: list(Player.t()),
          course: Course.t(),
          game_duration_seconds: integer(),
          timer: nil | {:interval, reference()},
          char_ownership: list(list(integer() | nil))
        }
end
