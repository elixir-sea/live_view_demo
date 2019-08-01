defmodule TypoKart.Dictionary.Random do
  @moduledoc """
  Random access to in-memory dictionary words.
  """

  alias TypoKart.Dictionary

  @spec word :: Dictionary.word()
  def word() do
    Dictionary.size()
    |> :random.uniform()
    |> Dictionary.get()
  end

  @spec words :: Stream.t(Dictionary.word())
  def words() do
    Stream.repeatedly(&word/0)
  end
end
