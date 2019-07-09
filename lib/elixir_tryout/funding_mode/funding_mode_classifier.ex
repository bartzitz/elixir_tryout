defmodule ElixirTryout.FundingModeClassifier do
  @prohibited "prohibited"
  @collection "collection"
  @receipts   "receipts"

  @from_client          "from_client"
  @obo_client           "obo_client"
  @obo_clients_custoner "obo_clients_custoner"

  def classify(sender, account, house_account) do
    funding_type = identify_funding_type
    if funding_type != PROHIBITED do
      funding_mode = identify_funding_mode(funding_type)
    end

    %{funding_type: funding_type, funding_mode: funding_mode}
  end

  defp identify_funding_type(sender, account, house_account) do
    case true do
      no_compliance_relationship?(account, house_account) ||
        nested_payments_with_collections?(sender, account, house_account) ||
        regulated_affiliate_receipts?(sender, account, house_account) -> @prohibited

      sender.not_account_holder? ||
        sender.approved_funding_partner? ||
        corporate_collections?(sender, account, house_account) -> @collection

      sender.account_holder? -> @receipts
    end
  end

  defp no_compliance_relationship?(account, house_account) do
    account.non_client? && (!house_account || house_account.non_client?)
  end

  defp nested_payments_with_collections?(sender, account, house_account) do
    is_regulated = if house_account do
                     house_account.regulated?
                   else
                     account.regulated?
                   end

    is_regulated && account.client? &&
      (sender.not_account_holder? || sender.approved_funding_partner?)
  end

  defp regulated_affiliate_receipts?(sender, account, house_account) do
    account.client? && sender.account_holder? &&
      house_account && house_account.non_client? && house_account.regulated?
  end

  defp corporate_collections?(sender, account, house_account) do
    account.non_client? && sender.account_holder? &&
      house_account && house_account.client? && house_account.unregulated?
  end

  defp nested_collections?(sender, account, house_account) do
    account.non_client? && house_account && house_account.client? && house_account.regulated? &&
      (sender.not_account_holder? || sender.approved_funding_partner?)
  end
end