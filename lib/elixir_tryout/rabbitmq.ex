defmodule RabbitMQ do
  use AMQP

  @url "amqp://guest:guest@localhost"

  @exchange "internal"
  @exchange_options [
    durable: true,
    arguments: [
      {"alternate-exchange", :longstr, "lost_messages_exchange"}
    ]
  ]
  @queue_options [
    arguments: [
      {"x-dead-letter-exchange", :longstr, "dead_letter_exchange"}
    ],
    durable: true,
    auto_delete: false,
    exclusive: false
  ]

  @queues [
    "funds_engine.calculatate_gbp_equivalent"
  ]

  def start_consumers do
    {:ok, conn} = Connection.open(@url)
    {:ok, channel} = Channel.open(conn)
    :ok = Exchange.direct(channel, @exchange, @exchange_options)

    for queue <- @queues do
      {:ok, _} = Queue.declare(channel, queue, @queue_options)
      :ok = Queue.bind(channel, queue, @exchange)
      {:ok, _consumer_tag} = Queue.subscribe(channel, queue, &process_message/2)
    end

    IO.puts "Waiting for messages ..."
  end

  def send_test_message do
    {:ok, conn} = Connection.open(@url)
    {:ok, channel} = Channel.open(conn)

    message = %{test: "message", status: "success"}
    {:ok, json} = Jason.encode(message)
    :ok = Basic.publish(channel, @exchange, "", json)
  end

  def process_message(payload, _meta) do
    IO.puts "Received message: #{payload}"
    :timer.sleep(2000)
    IO.puts "Processed message: #{payload}"
  end
end
