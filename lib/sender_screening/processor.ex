defmodule SenderScreening.Processor do
  alias ElixirTryout.Transaction

  def create_funds_originator(transaction, account_id) do
    update_transaction_funding_mode(transaction)
  end

  def update_transaction_funding_mode(transaction) do
    funds_originator = Transaction.get_funds_originator(transaction)

    if funds_originator && FundsOriginator.classified?(funds_originator) do
      FundingMode.Processor.classify_funding_mode(transaction)
    else
      FundingMode.Processor.reset_funding_mode(transaction)
    end

    calculate_screening_status(transaction)
  end
  
  defp calculate_screening_status(transaction) do
    funds_originator = Transaction.get_funds_originator(transaction)
    screening_status = SenderScreening.Status.calculate(transaction, funds_originator)

    changeset = Transaction.changeset(transaction, %{screening_status: screening_status})
    ElixirTryout.Repo.update(changeset)
  end
end
