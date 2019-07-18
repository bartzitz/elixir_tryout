defmodule ElixirTryout.ClassifierTest do
  use ExUnit.Case

  alias ElixirTryout.{Classifier,AccountClassification,Sender}

  @possible_combinations [
    # regulated_service  account             house_account     sender                 funding_type    funding_mode

    # receipts
    ["unregulated",      "client", nil, "account_holder", "receipts", "receipts_from_client"],
    ["regulated",        "client", nil, "account_holder", "receipts", "receipts_from_client"],
    ["unregulated",      "client", "client", "account_holder", "receipts", "receipts_from_client"],
    ["unregulated",      "client", "non-client", "account_holder", "receipts", "receipts_from_client"],
    ["regulated",        "client", "client", "account_holder", "receipts", "receipts_from_client"],
    ["regulated",        "non-client", "client", "account_holder", "receipts", "receipts_obo_client"],

    # collections
    ["unregulated",      "non-client", "client", "account_holder", "collections", "collections_obo_client"],
    ["unregulated",      "client", nil, "not_account_holder", "collections", "collections_obo_client"],
    ["unregulated",      "client", "client", "not_account_holder", "collections", "collections_obo_client"],
    ["unregulated",      "client", "non-client", "not_account_holder", "collections", "collections_obo_client"],
    ["unregulated",      "non-client", "client", "not_account_holder", "collections", "collections_obo_client"],
    ["regulated",        "non-client", "client", "not_account_holder", "collections", "collections_obo_clients_customer"],

    # prohibited
    ["unregulated",      "non-client", nil, "account_holder", "prohibited", nil],
    ["regulated",        "non-client", "non-client", "account_holder", "prohibited", nil],
    ["unregulated",      "non-client", "non-client", "account_holder", "prohibited", nil],
    ["regulated",        "client", "non-client", "account_holder", "prohibited", nil],
    ["regulated",        "non-client", nil, "account_holder", "prohibited", nil],
    ["unregulated",      "non-client", nil, "not_account_holder", "prohibited", nil],
    ["regulated",        "client", nil, "not_account_holder", "prohibited", nil],
    ["regulated",        "non-client", "non-client", "not_account_holder", "prohibited", nil],
    ["unregulated",      "non-client", "non-client", "not_account_holder", "prohibited", nil],
    ["regulated",        "client", "client", "not_account_holder", "prohibited", nil],
    ["regulated",        "client", "non-client", "not_account_holder", "prohibited", nil],
    ["regulated",        "non-client", nil, "not_account_holder", "prohibited", nil],
  ]

  test "classify/1" do
    Enum.each(@possible_combinations, fn row ->
      [regulated_service, account, house_account, sender_classification, funding_type, funding_mode] = row

      account_classification = %AccountClassification{regulated_service: regulated_service, compliance_relationship: account}
      house_account_classification =
        if house_account do
          %AccountClassification{regulated_service: regulated_service, compliance_relationship: house_account}
        else
          nil
        end

      sender = %Sender{classification: sender_classification}

      result = Classifier.classify(account_classification, house_account_classification, sender)

      assert result == {funding_type, funding_mode}, "| #{regulated_service} | #{account} | #{house_account} | #{sender_classification} | funding_type is #{funding_type}"
    end)
  end
end