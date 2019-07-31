defmodule TypoKart.Dictionary.Random do
  @spec word :: String.t()
  def word() do
    TypoKart.Dictionary.size()
    |> :random.uniform()
    |> TypoKart.Dictionary.get()
  end

  def words() do
    Stream.repeatedly(&word/0)
  end
end
