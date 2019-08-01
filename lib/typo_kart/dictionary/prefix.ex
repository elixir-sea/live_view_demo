defmodule TypoKart.Dictionary.Prefix do
  @moduledoc """
  In-memory access to dictionary by prefix.
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
  def lookup(prefix, exclude_self \\ False) do
    results =
      Enum.map(:ets.lookup(__MODULE__, prefix), fn {^prefix, pos} ->
        TypoKart.Dictionary.get(pos)
      end)

    if exclude_self do
      results -- [prefix]
    else
      results
    end
  end
end
