defmodule TypoKart.Dictionary.Word do
  @moduledoc """
  In-memory access to set of dictionary words by word.
  """

  use TypoKart.Dictionary.Index, type: :set

  alias TypoKart.Dictionary

  @spec insert(Dictionary.position(), Dictionary.word()) :: true
  def insert(position, word) do
    :ets.insert(__MODULE__, {word, position})
  end

  @spec lookup(Dictionary.word()) :: Dictionary.position() | false
  def lookup(word) do
    case :ets.lookup(__MODULE__, word) do
      [{^word, position}] -> position
      _ -> false
    end
  end
end
