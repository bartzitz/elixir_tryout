defmodule WorkersManager do
  use GenServer
  
  @process_name :workers_manager

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: @process_name)
  end

  def init(queues) do
    {:ok, queues}
  end

  def get_queues do
    Process.whereis(@process_name)
    |> GenServer.call(:get_queues)
  end

  def register_queue(queue_name) do
    queue_map = %{queue_name => %{}}

    Process.whereis(@process_name)
    |> GenServer.cast({:set_queues, queue_map})
  end

  def activate_queue(queue_name) do
    set_queue_attribute(queue_name, "is_active", true)
  end

  def deactivate_queue(queue_name) do
    set_queue_attribute(queue_name, "is_active", false)
  end

  def set_queue_attribute(queue_name, attr_name, attr_value) do
    queue_data = get_queues[queue_name]
    queue_map = %{queue_name => Map.put(queue_data, attr_name, attr_value)}

    set_queues(queue_map)
  end

  defp set_queues(queues) do
    Process.whereis(@process_name)
      |> GenServer.cast({:set_queues, queues})
  end

  def handle_call(:get_queues, _, queues) do
    {:reply, queues, queues}
  end

  def handle_cast({:set_queues, new_queues}, old_queues) do
    {:noreply, Map.merge(old_queues, new_queues)}
  end
end
