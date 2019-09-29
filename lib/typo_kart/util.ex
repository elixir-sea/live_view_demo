defmodule TypoKart.Util do
  @doc "DateTime.utc_now() wth :second truncation"
  @spec now() :: DateTime.t()
  def now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
