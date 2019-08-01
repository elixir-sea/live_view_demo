defmodule TypoKart.Dictionary.Index do
  defmodule Behaviour do
    alias TypoKart.Dictionary

    # Auto-defined
    @callback start_link(Supervisor.options()) :: :ignore | {:error, any} | {:ok, pid}
    @callback child_spec([]) :: Supervisor.child_spec()
    @callback size() :: non_neg_integer
    @callback exists?(any) :: bool

    # Needs definition
    @callback insert(Dictionary.position(), Dictionary.word()) :: true
    @callback lookup(any) :: any
  end

  defmacro __using__(type: type) do
    quote do
      @behaviour TypoKart.Dictionary.Index.Behaviour

      use Supervisor
      alias TypoKart.Dictionary

      @spec start_link(Supervisor.options()) :: :ignore | {:error, any} | {:ok, pid}
      def start_link(opts) do
        Supervisor.start_link(__MODULE__, :ok, opts)
      end

      @spec init(:ok) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
      def init(:ok) do
        Supervisor.init([__MODULE__], strategy: :one_for_one)
      end

      @spec child_spec([]) :: Supervisor.child_spec()
      def child_spec([]) do
        %{
          id: __MODULE__,
          start:
            {Eternal, :start_link,
             [
               __MODULE__,
               [unquote(type), read_concurrency: true],
               [name: __MODULE__, quiet: true]
             ]}
        }
      end

      @spec size :: non_neg_integer
      def size() do
        :ets.info(__MODULE__, :size)
      end

      @spec exists?(any) :: bool
      def exists?(index) do
        :ets.member(__MODULE__, index)
      end
    end
  end
end
