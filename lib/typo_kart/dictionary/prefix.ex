defmodule TypoKart.Dictionary.Prefix do
  @moduledoc """
  In-memory access to bag of dictionary words by prefix.
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
           [:bag, :compressed, read_concurrency: true],
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
