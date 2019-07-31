defmodule TypoKart.Dictionary.Prefix do
  @moduledoc """
  Interface to access to the TypoKart dictionary of words by prefix.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def child_spec([]) do
    %{
      id: __MODULE__,
      start:
        {Eternal, :start_link,
         [
           __MODULE__,
           [:bag, :compressed, read_concurrency: true],
           [name: __MODULE__, quiet: true]
         ]}
    }
  end

  @spec size :: non_neg_integer
  def size() do
    :ets.info(__MODULE__, :size)
  end

  @spec insert(non_neg_integer, String.t()) :: true
  def insert(pos, word) do
    prefixes =
      String.graphemes(word)
      |> Enum.scan(fn character, prefix ->
        prefix <> character
      end)
      |> Enum.map(fn prefix ->
        {prefix, pos}
      end)

    :ets.insert(__MODULE__, prefixes)
  end

  @spec lookup(String.t()) :: [String.t()]
  def lookup(prefix) do
    Enum.map(:ets.lookup(__MODULE__, prefix), fn {^prefix, pos} ->
      TypoKart.Dictionary.get(pos)
    end)
  end
end
