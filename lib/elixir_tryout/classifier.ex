defmodule ElixirTryout.Classifier do
  def classify(account, house_account, sender) do
    funding_type = calculate_funding_type(account, house_account, sender)
    funding_mode = calculate_funding_mode(funding_type, account, house_account, sender)
    full_funding_mode = if funding_mode, do: "#{funding_type}_#{funding_mode}"

    {funding_type, full_funding_mode}
  end

  def calculate_funding_type(account, house_account, sender) do
    cond do
      no_compliance_relationship?(account, house_account) ||
        nested_payments_with_collections?(account, house_account, sender) ||
        regulated_affiliate_receipts?(account, house_account) ->
        "prohibited"

      sender.classification == "not_account_holder" ||
        sender.classification == "approved_funding_partner" ||
        corporate_collections?(account, house_account, sender) ->
        "collections"

      sender.classification == "account_holder" ->
        "receipts"

      true ->
        nil
    end
  end

  def calculate_funding_mode(funding_type, account, house_account, sender) do
    case funding_type do
      "receipts" ->
        if account.compliance_relationship == "client" do
          "from_client"
        else
          "obo_client"
        end

      "collections" ->
        if nested_collections?(account, house_account, sender) do
          "obo_clients_customer"
        else
          "obo_client"
        end

      _ ->
        nil
    end
  end

  def no_compliance_relationship?(account, nil) do
    account.compliance_relationship == "non-client"
  end
  def no_compliance_relationship?(account, house_account) do
    account.compliance_relationship == "non-client" &&
      house_account.compliance_relationship == "non-client"
  end

  def nested_payments_with_collections?(account, nil, sender) do
    account.compliance_relationship == "client" && account.regulated_service == "regulated" &&
      (sender.classification == "not_account_holder" ||
         sender.classification == "approved_funding_partner")
  end
  def nested_payments_with_collections?(account, house_account, sender) do
    account.compliance_relationship == "client" && house_account.regulated_service == "regulated" &&
      (sender.classification == "not_account_holder" ||
         sender.classification == "approved_funding_partner")
  end

  def regulated_affiliate_receipts?(account, nil) do
    false
  end
  def regulated_affiliate_receipts?(account, house_account) do
    account.compliance_relationship == "client" &&
      house_account.compliance_relationship == "non-client" &&
      house_account.regulated_service == "regulated"
  end

  def corporate_collections?(account, nil, sender) do
    false
  end
  def corporate_collections?(account, house_account, sender) do
    account.compliance_relationship == "non-client" &&
      house_account.compliance_relationship == "client" &&
      house_account.regulated_service == "unregulated" &&
      sender.classification == "account_holder"
  end

  def nested_collections?(account, nil, sender) do
    false
  end
  def nested_collections?(account, house_account, sender) do
    account.compliance_relationship == "non-client" &&
      house_account.compliance_relationship == "client" &&
      house_account.regulated_service == "regulated" &&
      (sender.classification == "not_account_holder" ||
         sender.classification == "approved_funding_partner")
  end
end

defmodule ElixirTryout.AccountClassification do
  defstruct [:compliance_relationship, :regulated_service]
end

defmodule ElixirTryout.Sender do
  defstruct [:classification]
end