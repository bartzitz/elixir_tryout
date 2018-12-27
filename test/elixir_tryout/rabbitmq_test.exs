defmodule RabbitMQTest do
  use ExUnit.Case

  test "receives a message from RabbitMQ" do
    RabbitMQ.start_consumers()

    for _ <- 1..10 do
      RabbitMQ.send_test_message()
    end

    IO.puts "Waiting..."
    :timer.sleep(6000)
  end
end