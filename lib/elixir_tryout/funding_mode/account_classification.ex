defmodule ElixirTryout.AccountClassification do
  @enforce_keys [:compliance_relationship, :regulated_service]

  defstruct [:compliance_relationship, :regulated_service]

  def client?(account_classification) do
    account_classification.compliance_relationship == "client"
  end

  def non_client?(account_classification) do
    account_classification.compliance_relationship == "non-client"
  end

  def regulated?(account_classification) do
    account_classification.regulated_service == "regulated"
  end

  def unregulated?(account_classification) do
    account_classification.regulated_service == "unregulated"
  end
end
