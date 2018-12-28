defmodule ElixirTryout.FundingMode.Classifier do
  @prohibited :prohibited
  @collections :collections
  @receipts :receipts

  @from_client :from_clients
  @obo_client :obo_client
  @obo_client_customer :obo_client_customer

  def classify(funds_originator, account, house_account) do
    funding_type = identify_funding_type(funds_originator, account, house_account)

    funding_mode = funding_type |> identify_funding_mode()

    %{funding_type: funding_type, funding_mode: funding_mode}
  end

  def identify_funding_type(funds_originator, account, house_account) do
    "collections" # @todo: HARDCODED
  end

  def identify_funding_mode(funding_type \\ @prohibited, funds_originator, account, house_account) do
    if funding_type == @prohibited do
        nil
      else
        cond funding_type do
          funding_type == @receipts -> if account.client?, do: @from_client else: @obo_client
          funding_type == @collections ->
            if nested_payments_with_collections?(funds_originator, account, house_account), do: @from_client else: @obo_client
        end
    end
  end

  defp nested_payments_with_collections?(sender, account, house_account) do
    is_regulated = if house_account do: house_account.regulated? else: account.regulated?

    is_regulated && account.client? &&
      (sender.not_account_holder? || sender.approved_funding_partner?)
  end
end
