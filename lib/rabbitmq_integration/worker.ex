#  @exchange_names %{"direct"=> "internal", "fanout" => "internal-fanout", "topic" => "internal-topic", "headers" => "internal-headers"}
#  @queue       "elixir_tryout_test_queu"

defmodule Worker do
  def start do
    {:ok, conn} = AMQP.Connection.open("amqp://guest:guest@rabbitmq")
    {:ok, channel} = AMQP.Channel.open(conn)

    :ok = AMQP.Exchange.direct(channel, "internal",
      durable: true,
      arguments: [
        {"alternate-exchange", :longstr, "lost_messages_exchange"}
      ]
    )

    queue_options = [
      arguments: [
        {"x-dead-letter-exchange", :longstr, "dead_letter_exchange"}
      ],
      durable: true,
      auto_delete: false,
      exclusive: false
    ]

    queue_name = "funds_engine.calculatate_gbp_equivalent"
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, queue_name, queue_options)

    pid = spawn &wait_for_messages/0

    AMQP.Queue.bind(channel, queue_name, "internal")
    AMQP.Basic.consume(channel, queue_name, pid, no_ack: true)
    IO.puts "Waiting for messages ..."

    pid
  end

  def wait_for_messages do
    receive do
      {:basic_deliver, message, _meta} ->
        IO.puts "Received message:  #{message}"

        wait_for_messages()
    end
  end
end

defmodule Sender do
  def send do
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)

    message = "Here is test message!"

    AMQP.Exchange.declare(channel, "test_exchange", :direct)
    AMQP.Basic.publish(channel, "test_exchange", "", message)

    AMQP.Connection.close(connection)
  end
end

