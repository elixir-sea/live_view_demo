defmodule TypoKart.Dictionary do
  @moduledoc """
  Interface to access to the TypoKart dictionary of words.
  """

  use Supervisor

  alias TypoKart.Dictionary.Index
  alias TypoKart.Dictionary.Lookup
  alias TypoKart.Dictionary.Prefix
  alias TypoKart.Dictionary.Random

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    Supervisor.init(
      [
        Index,
        Lookup,
        Prefix
      ],
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  @spec load(path) :: :ok when path: String.t()
  def load(file \\ "priv/dictionary/words.txt") do
    IO.puts("loading dictionary, this may take a few minutes...")

    File.stream!(file)
    |> Stream.with_index()
    |> Stream.each(fn {line, pos} ->
      word = String.trim(line)
      IO.puts(word)

      Task.start(fn ->
        insert(pos, word)
      end)
    end)
    |> Stream.run()
  end

  @spec insert(non_neg_integer, String.t()) :: true
  def insert(pos, word) do
    Index.insert(pos, word)
    Lookup.insert(pos, word)
    Prefix.insert(pos, word)
  end

  @spec size :: non_neg_integer
  def size() do
    Index.size()
  end

  @spec get(non_neg_integer) :: false | String.t()
  def get(pos) do
    Index.lookup(pos)
  end

  @spec member?(String.t()) :: boolean
  def member?(word) do
    Lookup.word?(word)
  end

  @spec scan(String.t()) :: [String.t()]
  def scan(prefix) do
    Prefix.lookup(prefix)
  end

  @spec word() :: [String.t()]
  def word() do
    Random.word()
  end

  @spec words() :: Stream.t()
  def words() do
    Random.words()
  end
end
