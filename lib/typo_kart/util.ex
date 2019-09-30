defmodule TypoKart.Util do
  @doc "DateTime.utc_now() with the given precision: :second by default"
  @spec now(atom()) :: DateTime.t()
  def now(precision \\ :second) do
    DateTime.utc_now()
    |> DateTime.truncate(precision)
  end

  @doc "DateTime.utc_now() through to_unix with the given precision: :second by default"
  @spec now(atom()) :: DateTime.t()
  def now_unix(precision \\ :second) do
    DateTime.utc_now()
    |> DateTime.truncate(precision)
    |> DateTime.to_unix(precision)
  end
end
