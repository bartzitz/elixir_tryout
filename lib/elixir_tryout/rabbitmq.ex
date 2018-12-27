defmodule RabbitMQ do
  @url "amqp://guest:guest@localhost"
  @exchange "internal"
  @queues [
    "funds_engine.calculatate_gbp_equivalent"
  ]

  def start_consumers do
    {:ok, conn} = open_connection(@url)
    {:ok, channel} = open_channel(conn)
    :ok = declare_exchange(channel, @exchange)

    for queue <- @queues do
      {:ok, _} = declare_queue(channel, queue)
      :ok = bind_queue(channel, queue, @exchange)
      {:ok, _consumer_tag} = start_consumer(channel, queue)
    end

    IO.puts "Waiting for messages ..."
  end

  def send_test_message do
    {:ok, conn} = open_connection(@url)
    {:ok, channel} = open_channel(conn)

    message = %{test: "message", status: "success"}
    {:ok, json} = Jason.encode(message)
    :ok = publish_message(channel, @exchange, "", json)
  end

  def publish_message(channel, exchange, queue, message) do
    AMQP.Basic.publish(channel, exchange, queue, message, persistent: true, mandatory: true)
  end

  def open_connection(url) do
    AMQP.Connection.open(url)
  end

  def open_channel(connection) do
    AMQP.Channel.open(connection)
  end

  def declare_exchange(channel, exchange) do
    AMQP.Exchange.direct(
      channel,
      exchange,
      durable: true,
      arguments: [
        {"alternate-exchange", :longstr, "lost_messages_exchange"}
      ]
    )
  end

  def bind_queue(channel, queue, exchange) do
    IO.puts "Binding #{queue} to #{exchange}"
    AMQP.Queue.bind(channel, queue, exchange)
  end

  def declare_queue(channel, queue) do
    options = [
      arguments: [
        {"x-dead-letter-exchange", :longstr, "dead_letter_exchange"}
      ],
      durable: true,
      auto_delete: false,
      exclusive: false
    ]

    AMQP.Queue.declare(channel, queue, options)
  end

  def start_consumer(channel, queue) do
    AMQP.Queue.subscribe(channel, queue, &process_message/2)
  end

  def cancel_consumer(channel, consumer_tag) do
    AMQP.Basic.cancel(channel, consumer_tag)
  end

  def process_message(payload, _meta) do
    IO.puts "Received message: #{payload}"
    :timer.sleep(2000)
    IO.puts "Processed message: #{payload}"
  end
end
