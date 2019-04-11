defmodule Messaging.ConnectionManager do
  use GenServer
  use AMQP
  require Logger
  alias Messaging.Consumer

  @reconnect_timeout 5000

  defstruct [:url, :conn]

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    url = "amqp://guest:guest@localhost"

    # Process.flag(:trap_exit, true)

    silence_verbose_logging()
    connect()

    state = %__MODULE__{url: url, conn: nil}
    {:ok, state}
  end

  def connect() do
    GenServer.cast(__MODULE__, {:connect})
  end

  defp connect_with_retry(url) do
    case Connection.open(url) do
      {:ok, conn} ->
        Logger.info("Messaging: connected to broker")
        Process.monitor(conn.pid)
        {:ok, conn}

      _ ->
        Logger.warn("Messaging: connection failed, trying to reconnect...")
        :timer.sleep(@reconnect_timeout)
        connect_with_retry(url)
    end
  end

  def get_channel(consumer_pid) do
    GenServer.cast(__MODULE__, {:get_channel, consumer_pid})
  end

  defp silence_verbose_logging do
    :logger.add_primary_filter(
      :ignore_rabbitmq_progress_reports,
      {&:logger_filters.domain/2, {:stop, :equal, [:progress]}}
    )
  end

  #  Callbacks

  def handle_cast({:connect}, state) do
    {:ok, conn} = connect_with_retry(state.url)

    {:noreply, %{state | conn: conn}}
  end

  def handle_cast({:get_channel, consumer_pid}, state) do
    case Channel.open(state.conn) do
      {:ok, channel} ->
        Consumer.channel_opened(consumer_pid, channel)

      _ ->
        Consumer.channel_failed(consumer_pid)
    end

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    Logger.warn(
      "Messaging: connection went down #{inspect(pid)} #{inspect(ref)} #{inspect(reason)}"
    )

    connect()

    {:noreply, %{state | conn: nil}}
  end

  # def handle_info({:EXIT, _pid, reason}, state) do
  #   Logger.info("Messaging: EXIT connection error #{inspect reason}")
  #   Process.exit(self(), :kill)
  #   {:noreply, state}
  # end

  #  def terminate(reason, _state) do
  #    Logger.info("Messaging: shutting down gracefully... #{inspect reason}")
  #  end
end
