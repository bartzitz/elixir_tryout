defmodule ElixirTryoutWeb.RootView do
  use ElixirTryoutWeb, :view

  def approval_disabled(row) do
    if row.client_enabled do
      false
    else
      true
    end
  end
end