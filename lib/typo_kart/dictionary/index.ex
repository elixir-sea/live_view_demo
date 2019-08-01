defmodule TypoKart.Dictionary.Index do
  @moduledoc """
  In-memory access to set of dictionary words by numeric index.
  """

  use Supervisor

  alias TypoKart.Dictionary

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

  @spec insert(Dictionary.position(), Dictionary.word()) :: true
  def insert(position, word) do
    :ets.insert(__MODULE__, {position, word})
  end

  @spec lookup(Dictionary.position()) :: Dictionary.word() | false
  def lookup(position) do
    case :ets.lookup(__MODULE__, position) do
      [{^position, word}] -> word
      _ -> false
    end
  end

  @spec exists?(Dictionary.position()) :: bool
  def exists?(position) do
    :ets.member(__MODULE__, position)
  end
end
