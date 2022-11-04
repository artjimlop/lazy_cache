defmodule LazyCache do
  use GenServer

  @moduledoc """
  Documentation for LazyCache.
  """

  @doc """
  Start scheduling the works for clearing the cache.
  This method should be called before performing any operation.

  Returns `{:ok, PID}`.
  """
  @spec start() :: {atom, pid}
  def start() do
    GenServer.start_link(__MODULE__, %{})
  end

  @doc """
  Store anything for a certain amount of time or forever if no keep alive time specified

  Returns a boolean indicating if element has been correctly inserted.
  """
  @spec insert(term(), term(), :keep_alive_forever | number()) :: true | {:error, String.t()}
  def insert(key, value, keepAliveInMillis \\ :keep_alive_forever) do
    if not check_valid_keep_alive(keepAliveInMillis) do
      {:error,
       "Keep Alive Time is not valid. Should be a positive Integer or :keep_alive_forever."}
    else
      :ets.insert(
        :buckets_registry,
        {key, value, get_keepalive(keepAliveInMillis)}
      )
    end
  end

  @doc """
  Retrieve anything by its key.

  Returns `[{your_stored_tuple}]`.
  """
  def lookup(key) do
    :ets.lookup(:buckets_registry, key)
  end

  @doc """
  Delete anything by its key.

  Returns a boolean indicating if element has been correctly deleted.
  """
  def delete(key) do
    :ets.delete(:buckets_registry, key)
  end

  @doc """
  Obtain the number of elements stored in the cache.

  Returns an integer equals or bigger than zero.
  """
  @spec size() :: integer
  def size() do
    :ets.select_count(:buckets_registry, [{{:_, :_, :_}, [], [true]}])
  end

  @doc """
  Delete everything in the cache.

  Returns a boolean indicating if cache has been correctly cleared.
  """
  @spec clear() :: boolean
  def clear() do
    :ets.delete_all_objects(:buckets_registry)
  end

  defp get_keepalive(:keep_alive_forever), do: :keep_alive_forever
  defp get_keepalive(keepAliveInMillis) do
    :os.system_time(:millisecond) + keepAliveInMillis
  end

  defp check_valid_keep_alive(keepAliveInMillis) do
    keepAliveInMillis != nil and
      (keepAliveInMillis == :keep_alive_forever or
         (is_integer(keepAliveInMillis) and keepAliveInMillis > 0))
  end

  defp purge_cache() do
    now = :os.system_time(:millisecond)
    :ets.select_delete(:buckets_registry, [{{:_, :_, :"$1"}, [{:is_number, :"$1"}, {:"=<", :"$1", now}], [true]}])
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()
    # Create table
    :ets.new(:buckets_registry, [:set, :public, :named_table])
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the desired work here
    purge_cache()

    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # Each second
    Process.send_after(self(), :work, 1000)
  end
end
