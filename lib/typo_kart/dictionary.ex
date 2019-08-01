defmodule TypoKart.Dictionary do
  @moduledoc """
  Interface to access to the TypoKart dictionary of words.
  """

  use Supervisor

  alias TypoKart.Dictionary.Position
  alias TypoKart.Dictionary.Prefix
  alias TypoKart.Dictionary.Random
  alias TypoKart.Dictionary.Word

  @type word :: String.t()
  @type prefix :: String.t()
  @type position :: non_neg_integer

  @spec start_link(Supervisor.options()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @spec init(:ok) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(:ok) do
    Supervisor.init(
      [
        Position,
        Prefix,
        Word
      ],
      strategy: :one_for_one
    )
  end

  @spec load(path) :: :ok when path: String.t()
  def load(file \\ "priv/dictionary/words.txt") do
    IO.puts("loading dictionary, this may take a few minutes...")

    File.stream!(file)
    |> Stream.with_index()
    |> Stream.each(fn {line, position} ->
      word = String.trim(line)
      IO.puts(word)

      Task.start(fn ->
        insert(position, word)
      end)
    end)
    |> Stream.run()
  end

  @spec insert(position, word) :: true
  def insert(position, word) do
    Position.insert(position, word)
    Prefix.insert(position, word)
    Word.insert(position, word)
  end

  @doc "Returns size of dictionary."
  @spec size :: non_neg_integer
  def size() do
    Position.size()
  end

  @doc "Returns word at `position` in dictionary."
  @spec get(position) :: false | word
  def get(position) do
    Position.lookup(position)
  end

  @doc "Returns truthy if `word` exists in dictionary."
  @spec member?(word) :: boolean
  def member?(word) do
    Word.exists?(word)
  end

  @doc "Returns words starting with `prefix`."
  @spec scan(prefix, exclude) :: [word] when exclude: bool
  def scan(prefix, exclude \\ false) do
    if exclude do
      Prefix.lookup(prefix) -- [prefix]
    else
      Prefix.lookup(prefix)
    end
  end

  @doc "Returns random dictionary word."
  @spec word() :: word
  def word() do
    Random.word()
  end

  @doc "Returns stream of random dictionary words."
  @spec words() :: Stream.t(word)
  def words() do
    Random.words()
  end
end
