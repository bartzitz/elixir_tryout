defmodule Messaging.ConsumerSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    config = [
      ["internal", "funds_engine.calculatate_gbp_equivalent", &Messaging.WorkerExamples.gbp_message/2],
      ["internal", "other_queue", &Messaging.WorkerExamples.other_message/2]
    ]

    config
    |> Stream.with_index()
    |> Enum.map(&worker_spec/1)
    |> Supervisor.init(strategy: :one_for_one)
  end

  defp worker_spec({consumer_config, i}) do
    Supervisor.Spec.worker(Messaging.Consumer, consumer_config, id: {__MODULE__, i})
  end
end
