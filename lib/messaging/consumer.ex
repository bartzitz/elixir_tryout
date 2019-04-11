defmodule Messaging.Consumer do
  use GenServer
  use AMQP
  require Logger

  @reconnect_timeout 1000

  defstruct [:channel, :consumer_tag, :exchange, :queue, :handler_fn]

  def start_link(exchange, queue, handler_fn) do
    state = %__MODULE__{exchange: exchange, queue: queue, handler_fn: handler_fn}
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    get_channel()

    {:ok, state}
  end

  def channel_opened(pid, channel) do
    GenServer.cast(pid, {:channel_opened, channel})
  end

  def channel_failed(pid) do
    GenServer.cast(pid, {:channel_failed})
  end

  defp get_channel() do
    Messaging.ConnectionManager.get_channel(self())
  end

  defp subscribe_to_queue(channel, exchange, queue, handler_fn) do
    Process.monitor(channel.pid)

    :ok = Exchange.direct(channel, exchange, exchange_options())
    {:ok, _} = Queue.declare(channel, queue, queue_options())
    :ok = Queue.bind(channel, queue, exchange)
    {:ok, consumer_tag} = Queue.subscribe(channel, queue, handler_fn)

    Logger.info("Messaging: started consumer #{consumer_tag} on #{queue}")

    {:ok, consumer_tag}
  end

  def handle_cast({:channel_opened, channel}, state) do
    Logger.info("Messaging: channel opened for #{state.queue}")

    {:ok, consumer_tag} =
      subscribe_to_queue(channel, state.exchange, state.queue, state.handler_fn)

    {:noreply, %{state | channel: channel, consumer_tag: consumer_tag}}
  end

  def handle_cast({:channel_failed}, state) do
    Logger.warn("Messaging: failed to open channel for #{state.queue}, retrying...")
    :timer.sleep(@reconnect_timeout)
    get_channel()

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, object, reason}, state) do
    Logger.warn("Messaging: channel went down #{inspect(object)} #{inspect(reason)}")
    :timer.sleep(@reconnect_timeout)
    get_channel()

    {:noreply, state}
  end

  #  def cancel_consumer(channel, consumer_tag) do
  #    Basic.cancel(channel, consumer_tag)
  #  end

  #  def handle_info({:EXIT, _pid, reason}, state) do
  #    Logger.info("Messaging: EXIT consumer error #{inspect(reason)}")
  #    Process.exit(self(), :kill)
  #    {:noreply, state}
  #  end
  #
  #  def terminate(reason, _state) do
  #    Logger.info("Messaging: consumer shutting down gracefully... #{inspect(reason)}")
  #  end

  def exchange_options do
    [
      durable: true,
      arguments: [
        {"alternate-exchange", :longstr, "lost_messages_exchange"}
      ]
    ]
  end

  def queue_options do
    [
      arguments: [
        {"x-dead-letter-exchange", :longstr, "dead_letter_exchange"}
      ],
      durable: true,
      auto_delete: false,
      exclusive: false
    ]
  end
end
