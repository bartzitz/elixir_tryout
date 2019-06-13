defmodule ElixirTryout.FundingMode.AccountClassification do
  alias ElixirTryout.FundingMode.AccountClassification

  @enforce_keys [:compliance_relationship, :regulated_service]
  defstruct compliance_relationship: nil, regulated_service: nil

  def build(classification_params) when is_map(classification_params) do
    %AccountClassification{
      compliance_relationship: classification_params["compliance_relationship"],
      regulated_service: classification_params["regulated_service"]
    }
  end
  def build(_classification_params), do: nil

  def is_client(account_classification) do
    account_classification.compliance_relationship == "client"
  end

  def is_not_client(account_classification) do
    account_classification.compliance_relationship == "non-client"
  end

  def is_regulated(account_classification) do
    account_classification.regulated_service == "regulated"
  end

  def is_unregulated(account_classification) do
    account_classification.regulated_service == "unregulated"
  end
end
