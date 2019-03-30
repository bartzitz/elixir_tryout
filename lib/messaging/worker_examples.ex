defmodule Messaging.WorkerExamples do
  require Logger

  def gbp_message(payload, _meta) do
    Logger.info("=== gbp_message: #{inspect(payload)}")
  end

  def other_message(payload, _meta) do
    Logger.info("=== other_message: #{inspect(payload)}")
  end
end
