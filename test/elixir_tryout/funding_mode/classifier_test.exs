defmodule ElixirTryout.WebAdaptors.ClassifierTest do
  use ExUnit.Case

  test "#classify (generally works well)" do
    funds_originator = %ElixirTryout.FundsOriginator{
      free_text: "ololo",
      name: "name",
      address: "addr",
      account_id: "AAABB-CCC",
      status: "always_check",
      classification: "account_holder",
      account_details: "details..."
    }
    account = %ElixirTryout.FundingMode.Account{
      compliance_relationship: "client",
      regulated_service: "regulated"
    }

    house_account = %ElixirTryout.FundingMode.Account{
      compliance_relationship: "non-client",
      regulated_service: "unregulated"
    }

    context = %ElixirTryout.FundingMode.Classifier{
      sender: ElixirTryout.FundsOriginator.to_map(funds_originator),
      account: ElixirTryout.FundingMode.AccountClassification.to_map(account),
      house_account: ElixirTryout.FundingMode.AccountClassification.to_map(house_account)
    }

    %{funding_type: ft, funding_mode: fm} = ElixirTryout.FundingMode.Classifier.classify(context)
#    require IEx; IEx.pry

    assert ft == "collections"
    assert fm == "collections_obo_client"
  end
end
