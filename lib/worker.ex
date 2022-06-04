defmodule Chirinola.Worker do
  @doc """
  Documentation for `Worker` module.
  """

  use GenServer

  alias Chirinola.PlantTrait

  def start_link(), do: GenServer.start_link(__MODULE__, [])

  def insert(pid, element, file_name), do: GenServer.cast(pid, {:insert, element, file_name})

  @impl true
  def init(stack), do: {:ok, stack}

  @impl true
  def handle_cast({:insert, element, file_name}, state) do
    PlantTrait.migrate_line(element, file_name)

    {:noreply, state}
  end
end
