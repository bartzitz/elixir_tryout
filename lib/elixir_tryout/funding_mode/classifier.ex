defmodule ElixirTryout.FundingMode.Classifier do
  alias ElixirTryout.FundingMode.AccountClassification
  alias ElixirTryout.Sender

  @prohibited "prohibited"
  @collections "collections"
  @receipts "receipts"

  @from_client "from_client"
  @obo_client "obo_client"
  @obo_clients_customer "obo_clients_customer"

  def prohibited, do: @prohibited

  def identify_funding_type(account_classification, house_account_classification, sender) do
    cond do
      is_not_compliance_relationship(account_classification, house_account_classification) ||
        is_nested_payments_with_collections(account_classification, house_account_classification, sender) ||
        is_regulated_affiliate_receipts(account_classification, house_account_classification, sender) ->

        @prohibited
      Sender.is_not_account_holder(sender) ||
        Sender.is_approved_funding_partner(sender) ||
        is_corporate_collections(account_classification, house_account_classification, sender) ->

        @collections
      Sender.is_account_holder(sender) ->
        @receipts
      true -> raise "Can't identify funding_type"
    end
  end

  def identify_funding_mode(account_classification, house_account_classification, sender, funding_type) do
    funding_mode = case funding_type do
                     @receipts ->
                       if AccountClassification.is_client(account_classification), do: @from_client, else: @obo_client
                     @collections ->
                       if is_nested_collections(account_classification, house_account_classification, sender), do: @obo_clients_customer, else: @obo_client
                   end

    "#{funding_type}_#{funding_mode}"
  end

  defp is_not_compliance_relationship(account, house_account) do
    AccountClassification.is_not_client(account) &&
      (!house_account || AccountClassification.is_not_client(house_account))
  end

  defp is_nested_payments_with_collections(account, house_account, sender) do
    is_regulated = if house_account, do: AccountClassification.is_regulated(house_account), else: AccountClassification.is_regulated(account)

    is_regulated && AccountClassification.is_client(account) &&
      (Sender.is_not_account_holder(sender) || Sender.is_approved_funding_partner(sender))
  end

  defp is_regulated_affiliate_receipts(account, house_account, sender) do
    house_account && AccountClassification.is_client(account) && Sender.is_account_holder(sender) &&
      AccountClassification.is_not_client(house_account) && AccountClassification.is_regulated(house_account)
  end

  defp is_corporate_collections(account, house_account, sender) do
    house_account && AccountClassification.is_not_client(account) && Sender.is_account_holder(sender) &&
      AccountClassification.is_client(house_account) && AccountClassification.is_unregulated(house_account)
  end

  defp is_nested_collections(account, house_account, sender) do
    house_account && AccountClassification.is_client(house_account) && AccountClassification.is_regulated(house_account) &&
      AccountClassification.is_not_client(account) &&
      (Sender.is_not_account_holder(sender) || Sender.is_approved_funding_partner(sender))
  end
end
