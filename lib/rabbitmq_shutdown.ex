defmodule RabbitMQShutdown do
  use GenServer
  require Logger
  import Supervisor, only: [which_children: 1, terminate_child: 2]

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    Process.flag(:trap_exit, true)
    timeout = Keyword.get(options, :timeout, 20_000)
    
    {:ok, timeout}
  end

  def terminate(:shutdown, timeout), do: drain_consumers(timeout)
  def terminate({:shutdown, _}, timeout), do: drain_consumers(timeout)
  def terminate(:normal, timeout), do: drain_consumers(timeout)
  def terminate(_, _), do: :ok

  def drain_consumers(timeout) do
    Logger.info("Stopping existing consumers")
    stop_listening()

    Logger.info("Waiting for consumers to process messages")
    wait_for_requests(timeout)
  end

  def wait_for_requests(timeout) do
    Logger.info("LOGGER DrainStop starting graceful shutdown with timeout: #{timeout}")

    timer_ref = :erlang.start_timer(timeout, self, :timeout)

    do_wait_for_requests(timer_ref)
  end

  defp do_wait_for_requests(timer_ref) do
    all_consumers_stopped = WorkersManager.get_queues()
      |> Map.values
      |> Enum.all?(fn queue_data -> queue_data["is_active"] === false end)

    if all_consumers_stopped do
      Logger.info("DrainStop Successful, no more consumers")
      :erlang.cancel_timer(timer_ref)
    else
      :timer.sleep(1000)
      do_wait_for_requests(timer_ref)
    end
  end

  def stop_listening do
    WorkersManager.get_queues()
    |> Map.keys
    |> Enum.each(&(Worker.cancel_consumer &1))
  end
end
