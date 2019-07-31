defmodule TypoKart.Dictionary.Index do
  @moduledoc """
  Interface to access to the TypoKart dictionary of words.
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
           [:set, :compressed, read_concurrency: true],
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
    :ets.insert(__MODULE__, {pos, word})
  end

  @spec lookup(non_neg_integer) :: String.t() | false
  def lookup(pos) do
    case :ets.lookup(__MODULE__, pos) do
      [{^pos, word}] -> word
      _ -> false
    end
  end
end
