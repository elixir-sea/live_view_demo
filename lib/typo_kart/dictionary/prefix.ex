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

  @spec init(:ok) :: {:ok, {%{intensity: any, period: any, strategy: any}, [any]}}
  def init(:ok) do
    children = [__MODULE__]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec lookup(String.t()) :: [String.t()]
  def lookup(prefix) do
    Enum.map(:ets.lookup(__MODULE__, prefix), fn {^prefix, index} ->
      TypoKart.Dictionary.get(index)
    end)
  end
end
