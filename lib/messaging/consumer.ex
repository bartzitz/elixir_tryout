defmodule Messaging.Consumer do
  use GenServer
  use AMQP
  require Logger

  defstruct [:channel, :consumer_tag, :exchange, :queue, :handler_fn]

  def start_link(exchange, queue, handler_fn) do
    state = %__MODULE__{exchange: exchange, queue: queue, handler_fn: handler_fn}
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Logger.debug("Messaging: Consumer.init")
    Logger.info("Messaging: opening channel for #{state.queue}")

    # Process.flag(:trap_exit, true)

    Messaging.ConnectionManager.get_channel(self())
    {:ok, state}
  end

  def handle_cast({:channel_opened, channel}, %{exchange: exchange, queue: queue} = state) do
    Process.link(channel.pid)

    :ok = Exchange.direct(channel, exchange, exchange_options())
    {:ok, _} = Queue.declare(channel, queue, queue_options())
    :ok = Queue.bind(channel, queue, exchange)
    {:ok, consumer_tag} = Queue.subscribe(channel, queue, state.handler_fn)
    Logger.info("Messaging: started consumer #{consumer_tag} on #{queue}")

    {:noreply, %{state | channel: channel, consumer_tag: consumer_tag}}
  end

  def handle_info({:DOWN, _ref, :process, object, reason}, state) do
    Logger.info("Messaging: DOWN consumer error #{inspect object} #{inspect reason}")
    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.info("Messaging: EXIT consumer error #{inspect reason}")
    Process.exit(self(), :kill)
    {:noreply, state}
  end

  def terminate(reason, _state) do
    Logger.info("Messaging: consumer shutting down gracefully... #{inspect reason}")
  end

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

  def cancel_consumer(channel, consumer_tag) do
    Basic.cancel(channel, consumer_tag)
  end

  # def handle_info(args, state) do
  #   Logger.info("==== Got process message: #{inspect(args)}")
  #   {:noreply, state}
  # end
end
