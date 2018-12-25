#  @exchange_names %{"direct"=> "internal", "fanout" => "internal-fanout", "topic" => "internal-topic", "headers" => "internal-headers"}
#  @queue       "elixir_tryout_test_queu"

defmodule Worker do
  def start do
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)

    AMQP.Exchange.declare(channel, "test_exchange", :direct)
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
    AMQP.Queue.bind(channel, queue_name, "test_exchange")
    AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
    IO.puts "Waiting for messages ..."

    wait_for_messages(channel)
  end

  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, message, _meta} ->
        IO.puts "Received message:  #{message}"

        wait_for_messages(channel)
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

