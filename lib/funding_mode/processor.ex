defmodule FundingMode.Processor do
  alias ElixirTryout.Transaction

  def reset_funding_mode(transaction) do
    changeset = Transaction.changeset(transaction, %{funding_type: nil, funding_mode: nil})

    ElixirTryout.Repo.update(changeset)
  end

  def classify_funding_mode(transaction) do
    {acc_classification, house_acc_classification} = get_account_classification(transaction)

    cond do
      !valid_account_classification?(acc_classification) -> false
      house_acc_classification && !valid_houst_account_classification?(house_acc_classification) -> false
      true ->
        funds_originator = Transaction.get_funds_originator(transaction)

        classifier_struct = %FundingMode.Classifier{sender: funds_originator, account: acc_classification, house_account: house_acc_classification}
        {funding_type, funding_mode} = FundingMode.Classifier.classify(classifier_struct)

        changeset = Transaction.changeset(transaction, %{funding_type: funding_type,  funding_mode: funding_mode})
        ElixirTryout.Repo.update(changeset)
    end
  end

  defp get_account_classification(transaction) do
    # TODO implement sevice which will fetch data from crm and return a touple
    {"account_classification", "house_account_classification"}
  end
end
