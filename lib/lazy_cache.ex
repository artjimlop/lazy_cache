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
  def insert(key, value, keepAliveInMillis \\ :keep_alive_forever) do
    if not check_valid_keep_alive(keepAliveInMillis) do
      {:error,
       "Keep Alive Time is not valid. Should be a positive Integer or :keep_alive_forever."}
    else
      is_inserted =
        :ets.insert(
          :buckets_registry,
          {key, value, get_keepalive(keepAliveInMillis)}
        )

      get_keyset()
      |> check_if_key_already_in_keyset(key)

      if is_inserted do
        append_to_keyset(get_keyset(), key)
      end

      is_inserted
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
    is_deleted = :ets.delete(:buckets_registry, key)

    if is_deleted do
      delete_from_keyset(get_keyset(), key)
    end

    is_deleted
  end

  @doc """
  Obtain the number of elements stored in the cache.

  Returns an integer equals or bigger than zero.
  """
  @spec size() :: integer
  def size() do
    length(get_keyset())
  end

  @doc """
  Delete everything in the cache.

  Returns a boolean indicating if cache has been correctly cleared.
  """
  @spec clear() :: boolean
  def clear() do
    if size() == 0 do
      false
    else
      for key <- get_keyset(), do: delete(key)
      true
    end
  end

  defp get_keepalive(keepAliveInMillis) do
    if keepAliveInMillis == :keep_alive_forever do
      :keep_alive_forever
    else
      :os.system_time(:milli_seconds) + keepAliveInMillis
    end
  end

  defp check_valid_keep_alive(keepAliveInMillis) do
    keepAliveInMillis != nil and
      (keepAliveInMillis == :keep_alive_forever or
         (is_integer(keepAliveInMillis) and keepAliveInMillis > 0))
  end

  defp update_key_set(key_set) do
    :ets.delete(:key_set, :keys)
    :ets.insert(:key_set, {:keys, key_set})
  end

  defp check_if_key_already_in_keyset(key_set, key) do
    if Enum.member?(key_set, key) do
      delete_from_keyset(key_set, key)
    end
  end

  defp delete_from_keyset(key_set, key) do
    List.delete(key_set, key)
    |> update_key_set()
  end

  defp append_to_keyset(key_set, key) do
    (key_set ++ [key])
    |> update_key_set()
  end

  defp purge(key) do
    [element] = lookup(key)

    if(elem(element, 2) <= :os.system_time(:milli_seconds)) do
      delete(key)
    end
  end

  defp purge_cache() do
    if size() > 0 do
      for key <- get_keyset(), do: purge(key)
    end
  end

  defp get_keyset() do
    :ets.lookup(:key_set, :keys)[:keys]
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()
    # Create table
    :ets.new(:buckets_registry, [:set, :public, :named_table])
    :ets.new(:key_set, [:set, :public, :named_table])
    :ets.insert(:key_set, {:keys, []})
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
