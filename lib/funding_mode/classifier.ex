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
      classifier_struct |> validate_data([&no_compliance_relationship?/1, &nested_payments_with_collections?/1, &regulated_affiliate_receipts?/1]) -> prohibited()
    end
  end

  def no_compliance_relationship?(val), do: true
  def nested_payments_with_collections?(val), do: true
  def regulated_affiliate_receipts?(val), do: true

  def prohibited, do: "prohibited"
  def collections, do: "collections"
  def receipts, do: "receipts"

  def from_client, do: "from_client"
  def obo_client, do: "obo_client"
  def obo_clients_customer, do: "obo_clients_customer"

  def validate_data(value, functions) do
    functions
    |> Enum.map(fn function -> function.(value)  end)
    |> Enum.any
  end
end
