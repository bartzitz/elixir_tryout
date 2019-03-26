defmodule Messaging.ConnectionManager do
  use GenServer
  use AMQP
  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Logger.debug("Messaging: ConnectionManager.init")
    url = "amqp://guest:guest@localhost"

    # Process.flag(:trap_exit, true)

    silence_verbose_logging()
    {:ok, conn} = connect(url)
    {:ok, _} = start_consumers()
    {:ok, conn}
  end

  def get_channel(consumer_pid) do
    Logger.debug("Messaging: ConnectionManager.get_channel")
    GenServer.cast(__MODULE__, {:get_channel, consumer_pid})
    # GenServer.call(__MODULE__, {:get_channel, consumer_pid})
  end

  def handle_cast({:get_channel, consumer_pid}, conn) do
    {:ok, channel} = Channel.open(conn)
    GenServer.cast(consumer_pid, {:channel_opened, channel})
    {:noreply, conn}
  end

  def handle_call({:get_channel, _consumer_pid}, _from, conn) do
    Logger.debug("Got a call")
    {:ok, channel} = Channel.open(conn)
    # GenServer.cast(consumer_pid, {:channel_opened, channel})
    {:reply, channel, conn}
  end

  def handle_info({:DOWN, _ref, :process, object, reason}, state) do
    Logger.info("Messaging: DOWN connection error #{inspect object} #{inspect reason}")
    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.info("Messaging: EXIT connection error #{inspect reason}")
    Process.exit(self(), :kill)
    {:noreply, state}
  end

  def terminate(reason, _state) do
    Logger.info("Messaging: shutting down gracefully... #{inspect reason}")
  end

  defp connect(url) do
    case Connection.open(url) do
      {:ok, conn} ->
        Logger.info("Messaging: connected to broker")
        Process.link(conn.pid)
        {:ok, conn}

      {:error, _} ->
        Logger.warn("Messaging: connection failed, reconnecting in 5 secs...")
        :timer.sleep(5000)
        connect(url)
    end
  end

  defp start_consumers do
    import Supervisor.Spec

    config = [
      ["internal", "funds_engine.calculatate_gbp_equivalent", &Messaging.GBPWorker.on_message/2],
      ["internal", "other_queue", &Messaging.GBPWorker.other_message/2]
    ]

    children =
      config
      |> Stream.with_index()
      |> Enum.map(fn {[exchange, queue, handler_fn], i} ->
        worker(Messaging.Consumer, [exchange, queue, handler_fn], id: {__MODULE__, i})
      end)

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp silence_verbose_logging do
    :logger.add_primary_filter(
      :ignore_rabbitmq_progress_reports,
      {&:logger_filters.domain/2, {:stop, :equal, [:progress]}}
    )
  end

  # def handle_info({:DOWN, _, :process, _pid, reason}, _) do
  # def handle_info(message, state) do
  #   Logger.warn "Messaging: handle_info: #{inspect message}"

  #   {:noreply, state}
  # end
end
