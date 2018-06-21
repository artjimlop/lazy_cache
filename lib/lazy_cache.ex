defmodule LazyCache do
  use GenServer

  @moduledoc """
  Documentation for LazyCache.
  """

  @doc """
  Start scheduling the works for clearing the DB.

  ## Examples

      iex> LazyCache.start
      {:ok, #PID<0.112.0>}

  """
  def start do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the desired work here
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    # In 2 seconds
    Process.send_after(self(), :work, 2 * 1000)
  end
end
