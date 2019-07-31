defmodule TypoKart.Dictionary.Lookup do
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
    :ets.insert(__MODULE__, {word, pos})
  end

  @spec pos(String.t()) :: non_neg_integer | false
  def pos(word) do
    case :ets.lookup(__MODULE__, word) do
      [{^word, pos}] -> pos
      _ -> false
    end
  end

  @spec word?(String.t()) :: bool
  def word?(word) do
    :ets.member(__MODULE__, word)
  end
end
