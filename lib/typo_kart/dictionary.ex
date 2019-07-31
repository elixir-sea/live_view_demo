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
    File.stream!(file)
    |> Stream.with_index()
    |> Stream.each(fn {line, index} ->
      :ets.insert(__MODULE__, {index, String.trim(line)})
    end)
    |> Stream.run()
  end

  @spec size :: integer
  def size() do
    :ets.info(__MODULE__, :size)
  end

  @spec word :: String.t()
  def word() do
    case words(1) do
      [word] -> word
      _ -> false
    end
  end

  @spec words(integer) :: [String.t()]
  def words(number) do
    Stream.repeatedly(fn ->
      index = :random.uniform(size())

      case :ets.lookup(__MODULE__, index) do
        [{^index, word}] -> word
        _ -> false
      end
    end)
    |> Stream.reject(&is_nil/1)
    |> Enum.take(number)
  end
end
