defmodule Chirinola.Worker do
  @doc """
  Documentation for `Worker` module.
  """

  use GenServer

  alias Chirinola.PlantTrait

  # Client

  def start_link(), do: GenServer.start_link(__MODULE__, [])

  def insert(pid, element), do: GenServer.cast(pid, {:insert, element})

  def insert_all(pid, element), do: GenServer.cast(pid, {:insert, element})

  # Server (callbacks)

  @impl true
  def init(stack), do: {:ok, stack}

  @impl true
  def handle_cast({:insert, element}, state) do
    PlantTrait.insert(element)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:insert_all, elements}, state) do
    PlantTrait.insert_all(elements)

    {:noreply, state}
  end
end
