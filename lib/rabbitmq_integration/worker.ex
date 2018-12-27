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
    WorkersManager.register_queue(queue_name)

    pid = spawn &wait_for_messages/0

    AMQP.Queue.bind(channel, queue_name, "internal")
    {:ok, consumer_tag} = AMQP.Basic.consume(channel, queue_name, pid, no_ack: true)

    IO.puts "Waiting for messages ..."

    WorkersManager.set_queue_attribute(queue_name, "channel", channel)
    WorkersManager.set_queue_attribute(queue_name, "consumer_tag", consumer_tag)

    {channel, consumer_tag}
  end

  def wait_for_messages do
    queue_name = "funds_engine.calculatate_gbp_equivalent"

    receive do
      {:basic_deliver, message, _meta} ->
        IO.puts "Received message:  #{message}"
        WorkersManager.activate_queue(queue_name)

        :timer.sleep(15000)

        IO.puts "Processed message:  #{message}"

        WorkersManager.deactivate_queue(queue_name)
        wait_for_messages()
    end
  end

  def cancel_consumer(queue_name) do
    queue_data = WorkersManager.get_queues()[queue_name]

    AMQP.Basic.cancel(queue_data["channel"], queue_data["consumer_tag"])
  end
end

defmodule Sender do
  def send(number) do
    {:ok, connection} = AMQP.Connection.open("amqp://guest:guest@rabbitmq")
    {:ok, channel} = AMQP.Channel.open(connection)

    message = "Here is test message! ##{number}"

    :ok = AMQP.Exchange.direct(channel, "internal",
      durable: true,
      arguments: [
        {"alternate-exchange", :longstr, "lost_messages_exchange"}
      ]
    )

    AMQP.Basic.publish(channel, "internal", "funds_engine.calculatate_gbp_equivalent", message)

    AMQP.Channel.close(channel)
    AMQP.Connection.close(connection)
  end
end

