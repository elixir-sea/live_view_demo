defmodule TypoPaint.Player do
  alias TypoPaint.PathCharIndex

  defstruct id: "",
            color: "",
            label: "",
            points: 0,
            view_pid: nil,
            cur_path_char_indices: [%PathCharIndex{}]

  @type t :: %__MODULE__{
          id: binary(),
          color: binary(),
          label: binary(),
          points: integer(),
          view_pid: nil | pid(),
          cur_path_char_indices: list(PathCharIndex.t())
        }
end
