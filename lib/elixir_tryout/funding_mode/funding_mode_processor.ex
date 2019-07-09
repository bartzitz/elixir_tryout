defmodule ElixirTryout.FundingModeProcessor do
  def classify_funding_mode(transaction) do
    %{
      account_classifacation: account_classification,
      house_account_classification: house_account_classification
    } = fetch_account_classification(transaction)


  end

  defp fetch_account_classification(transaction) do
    # Hardcoded values
    account_classifacation = %{compliance_relationship: "non-client", regulated_service: "regulated"}
    house_account_classification = %{compliance_relationship: "client", regulated_service: "regulated"}

    %{
      account_classifacation: struct(ElixirTryout.AccountClassification, account_classifacation),
      house_account_classification: struct(ElixirTryout.AccountClassification, house_account_classification)
    }
  end
end