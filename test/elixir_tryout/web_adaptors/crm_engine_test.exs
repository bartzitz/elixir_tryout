defmodule ElixirTryout.WebAdaptors.CrmEngineTest do
  use ExUnit.Case

  test "calls find endpoint" do
    res = ElixirTryout.WebAdaptors.CrmEngine.find_accounts(%{rfx_ref: "160420-00008"})

    %{"status" => status, "data" => _} = res

    assert status == 200
  end
end


