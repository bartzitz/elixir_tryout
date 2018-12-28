defmodule FundingMode.Classifier do
  defstruct [:sender, :account, :house_account]

  def classify(classifier_struct) do
    funding_type = identify_funding_type(classifier_struct)

    if funding_type == prohibited() do
      {funding_type, nil}
    else
      funding_mode = identify_funding_mode(funding_type, classifier_struct)
      {funding_type, funding_mode}
    end
  end

  def identify_funding_type(classifier_struct) do
    cond do
      no_compliance_relationship?(classifier_struct) || nested_payments_with_collections?(classifier_struct) || regulated_affiliate_receipts? -> prohibited()
    end
  end

  def prohibited, do: "prohibited"
  def collections, do: "collections"
  def receipts, do: "receipts"

  def from_client, do: "from_client"
  def obo_client, do: "obo_client"
  def obo_clients_customer, do: "obo_clients_customer"
end
