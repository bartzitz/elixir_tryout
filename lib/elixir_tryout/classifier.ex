defmodule ElixirTryout.AccountClassification do
  defstruct [:compliance_relationship, :regulated_service]
end

defmodule ElixirTryout.Sender do
  defstruct [:classification]
end

defmodule ElixirTryout.MappedAccount do
  defstruct [:client?, :non_client?, :regulated?, :unregulated?]

  def map_from(nil) do
    nil
  end

  def map_from(account) do
    %ElixirTryout.MappedAccount{
      client?: account.compliance_relationship == "client",
      non_client?: account.compliance_relationship == "non-client",
      regulated?: account.regulated_service == "regulated",
      unregulated?: account.regulated_service == "unregulated"
    }
  end
end

defmodule ElixirTryout.MappedSender do
  defstruct [:account_holder?, :not_account_holder?]

  def map_from(sender) do
    %ElixirTryout.MappedSender{
      account_holder?: sender.classification == "account_holder",
      not_account_holder?:
        sender.classification == "not_account_holder" ||
          sender.classification == "approved_funding_partner"
    }
  end
end

defmodule ElixirTryout.Classifier do
  alias ElixirTryout.{MappedAccount, MappedSender}

  def classify(account_classification, house_account_classification, sender) do
    account = MappedAccount.map_from(account_classification)
    house_account = MappedAccount.map_from(house_account_classification)
    mapped_sender = MappedSender.map_from(sender)

    funding_type = calculate_funding_type(account, house_account, mapped_sender)
    funding_mode = calculate_funding_mode(funding_type, account, house_account, mapped_sender)
    full_funding_mode = if funding_mode, do: "#{funding_type}_#{funding_mode}"

    {funding_type, full_funding_mode}
  end

  def calculate_funding_type(account, house_account, sender) do
    cond do
      no_compliance_relationship?(account, house_account) ->
        "prohibited"

      nested_payments_with_collections?(account, house_account, sender) ->
        "prohibited"

      regulated_affiliate_receipts?(account, house_account) ->
        "prohibited"

      sender.not_account_holder? ->
        "collections"

      corporate_collections?(account, house_account, sender) ->
        "collections"

      sender.account_holder? ->
        "receipts"

      true ->
        nil
    end
  end

  def calculate_funding_mode("receipts", account, _house_account, _sender) do
    if account.client? do
      "from_client"
    else
      "obo_client"
    end
  end

  def calculate_funding_mode("collections", account, house_account, sender) do
    if nested_collections?(account, house_account, sender) do
      "obo_clients_customer"
    else
      "obo_client"
    end
  end

  def calculate_funding_mode(_, _account, _house_account, _sender) do
    nil
  end

  def no_compliance_relationship?(account, nil) do
    account.non_client?
  end

  def no_compliance_relationship?(account, house_account) do
    account.non_client? && house_account.non_client?
  end

  def nested_payments_with_collections?(account, nil, sender) do
    account.client? && account.regulated? && sender.not_account_holder?
  end

  def nested_payments_with_collections?(account, house_account, sender) do
    account.client? && house_account.regulated? && sender.not_account_holder?
  end

  def regulated_affiliate_receipts?(_account, nil) do
    false
  end

  def regulated_affiliate_receipts?(account, house_account) do
    account.client? && house_account.non_client? && house_account.regulated?
  end

  def corporate_collections?(_account, nil, _sender) do
    false
  end

  def corporate_collections?(account, house_account, sender) do
    account.non_client? && house_account.client? && house_account.unregulated? &&
      sender.account_holder?
  end

  def nested_collections?(_account, nil, _sender) do
    false
  end

  def nested_collections?(account, house_account, sender) do
    account.non_client? && house_account.client? && house_account.regulated? &&
      sender.not_account_holder?
  end
end
