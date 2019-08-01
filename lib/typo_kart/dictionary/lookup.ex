defmodule TypoKart.Dictionary.Lookup do
  @moduledoc """
  In-memory access to dictionary by word.
  """

  use Supervisor

  @spec start_link(Supervisor.options()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @spec init(:ok) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(:ok) do
    Supervisor.init(
      [__MODULE__],
      strategy: :one_for_one
    )
  end

  @spec child_spec([]) :: Supervisor.child_spec()
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
