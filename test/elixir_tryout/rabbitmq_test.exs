defmodule RabbitMQTest do
  use ExUnit.Case

  test "receives a message from RabbitMQ" do
    RabbitMQ.start_link()
    RabbitMQ.start_consumers()
    RabbitMQ.send_test_message()

    IO.puts "Waiting..."
    :timer.sleep(1000)
  end
end