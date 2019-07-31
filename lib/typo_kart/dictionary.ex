defmodule TypoKart.Dictionary do
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

  def init(:ok) do
    children = [__MODULE__]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec load(path) :: :ok when path: String.t()
  def load(file \\ "priv/dictionary/words.txt") do
    IO.puts("loading dictionary, this may take a few minutes...")

    File.stream!(file)
    |> Stream.with_index()
    |> Stream.each(fn {line, pos} ->
      Task.start(fn ->
        insert(pos, String.trim(line))
      end)
    end)
    |> Stream.run()
  end

  def insert(pos, word) do
    :ets.insert(__MODULE__, {pos, word})

    prefixes =
      String.graphemes(word)
      |> Enum.scan(fn character, prefix ->
        prefix <> character
      end)
      |> Enum.map(fn prefix ->
        {prefix, pos}
      end)

    :ets.insert(__MODULE__.Prefix, prefixes)
  end

  @spec size :: integer
  def size() do
    :ets.info(__MODULE__, :size)
  end

  def get(pos) do
    case :ets.lookup(__MODULE__, pos) do
      [{^pos, word}] -> word
      _ -> false
    end
  end
end
