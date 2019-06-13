defmodule ElixirTryout.FundingMode.ClassificationProcessor do
  alias ElixirTryout.FundingMode.Classifier
  alias ElixirTryout.FundingMode.AccountClassification

  import ElixirTryout.WebAdaptors.CrmEngine

  def classify_funding_mode(transaction) do
    sender = transaction.sender

    try do
      {account, house_account} = fetch_account_classification(sender.account_id)

      funding_type = Classifier.identify_funding_type(account, house_account, sender)
      funding_mode = if funding_type == Classifier.prohibited(), do: Classifier.identify_funding_mode(account, house_account, sender, funding_type)

      changeset = ElixirTryout.Transaction.changeset(transaction, %{funding_mode: funding_mode, funding_type: funding_type})
      ElixirTryout.Repo.update(changeset)
    rescue
      error in RuntimeError -> error
    end
  end

  def reset_funding_mode(transaction) do
    changeset = ElixirTryout.Transaction.changeset(transaction, %{funding_mode: nil, funding_type: nil})
    ElixirTryout.Repo.update(changeset)
  end

  defp fetch_account_classification(account_id) do
    response = get_account_classification(account_id)

    {
      AccountClassification.build(response["account_classification"]),
      AccountClassification.build(response["house_account_classification"])
    }
  end
end
