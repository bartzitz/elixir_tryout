defmodule Messaging.GBPWorker do
  require Logger

  def on_message(payload, _meta) do
    Logger.info "GBPWorker: got message #{inspect payload}"
  end

  def other_message(payload, _meta) do
    Logger.info "OTHER messag! #{payload}"
  end
end
