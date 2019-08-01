defmodule TypoKart.Dictionary.Prefix do
  @moduledoc """
  In-memory access to bag of dictionary words by prefix.
  """

  use TypoKart.Dictionary.Index, type: :bag

  alias TypoKart.Dictionary

  @spec insert(Dictionary.position(), Dictionary.word()) :: true
  def insert(position, word) do
    prefixes =
      String.graphemes(word)
      |> Enum.scan(fn character, prefix ->
        prefix <> character
      end)
      |> Enum.map(fn prefix ->
        {prefix, position}
      end)

    :ets.insert(__MODULE__, prefixes)
  end

  @spec lookup(Dictionary.prefix()) :: [Dictionary.word()]
  def lookup(prefix) do
    Enum.map(:ets.lookup(__MODULE__, prefix), fn {^prefix, position} ->
      TypoKart.Dictionary.get(position)
    end)
  end
end
