defmodule TypoKart.Dictionary.Position do
  @moduledoc """
  In-memory access to set of dictionary words by numeric index.
  """

  use TypoKart.Dictionary.Index, type: :set

  alias TypoKart.Dictionary

  @spec insert(Dictionary.position(), Dictionary.word()) :: true
  def insert(position, word) do
    :ets.insert(__MODULE__, {position, word})
  end

  @spec lookup(Dictionary.position()) :: Dictionary.word() | false
  def lookup(position) do
    case :ets.lookup(__MODULE__, position) do
      [{^position, word}] -> word
      _ -> false
    end
  end
end
