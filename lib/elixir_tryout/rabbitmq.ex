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

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_consumers do
    {:ok, conn} = Connection.open(@url)
    {:ok, channel} = Channel.open(conn)
    :ok = Exchange.direct(channel, @exchange, @exchange_options)

    for queue <- @queues do
      {:ok, _} = Queue.declare(channel, queue, @queue_options)
      :ok = Queue.bind(channel, queue, @exchange)
      {:ok, _consumer_tag} = Queue.subscribe(channel, queue, &process_message/2)
    end

    IO.puts "Supervisor: waiting for messages ..."
  end

  def send_test_message do
    {:ok, conn} = Connection.open(@url)
    {:ok, channel} = Channel.open(conn)

    for i <- 1..3 do
      message = %{index: i, test: "message"}
      {:ok, json} = Jason.encode(message)
      :ok = Basic.publish(channel, @exchange, "", json)
    end
  end

  def process_message(payload, meta) do
    IO.puts "Supervisor: received message: #{payload}"

    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, RabbitMQ.Worker)
    RabbitMQ.Worker.handle_message(pid, payload, meta)
  end
end

defmodule RabbitMQ.Worker do
  use GenServer

  # Client API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def handle_message(pid, payload, meta) do
    GenServer.cast(pid, {:handle_message, payload, meta})
  end

  # Server API
  def init(args) do
    IO.puts "Worker: starting"

    Process.flag(:trap_exit, true)
    {:ok, args}
  end

  def handle_cast({:handle_message, payload, _meta}, state) do
    IO.puts "Worker: started handling message: #{payload}"
    :timer.sleep(2000)
    IO.puts "Worker: finished handling message: #{payload}"

    {:noreply, state}
  end

  def terminate(reason, _state) do
    IO.puts "Worker: terminating: #{inspect self()}: #{inspect reason}"
    :ok
  end
end
