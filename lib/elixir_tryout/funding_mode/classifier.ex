defmodule ElixirTryout.FundingMode.Account do
  defstruct [:compliance_relationship, :regulated_service]
end

defmodule ElixirTryout.FundingMode.AccountClassification do
  alias ElixirTryout.FundingMode.Account
  defstruct [:client?, :non_client?, :regulated?, :unregulated?]

  def client?(%Account{} = account) do
    account.compliance_relationship == "client"
  end

  def non_client?(%Account{} = account) do
    account.compliance_relationship == "non-client"
  end

  def regulated?(%Account{} = account) do
    account.regulated_service == "regulated"
  end

  def unregulated?(%Account{} = account) do
    account.regulated_service == "unregulated"
  end

  # @todo: refactor to use with pipe ||>
  def to_map(%Account{} = account) do
    %{
      client?: client?(account),
      non_client?: non_client?(account),
      regulated?: regulated?(account),
      unregulated?: unregulated?(account)
    }
  end
end


defmodule ElixirTryout.FundingMode.Classifier do
  alias __MODULE__

  @prohibited :prohibited
  @collections :collections
  @receipts :receipts

  @from_client :from_clients
  @obo_client :obo_client
  @obo_client_customer :obo_client_customer

  defstruct [:sender, :account, :house_account]

  def classify(%Classifier{} = context) do
    funding_type = identify_funding_type(context)
    require IEx; IEx.pry

    funding_mode = if funding_type != @prohibited, do: identify_funding_mode(funding_type, context), else: nil


    %{funding_type: funding_type, funding_mode: funding_mode}
  end

  def identify_funding_type(_context) do
    :collections # @todo: HARDCODED
  end

  def identify_funding_mode(funding_type, context) do
    funding_mode = if funding_type == @prohibited do
      nil
    else
      cond do
        funding_type == @receipts -> if context.account.client?, do: @from_client, else: @obo_client
        funding_type == @collections -> if nested_payments_with_collections?(context), do: @obo_client_customer, else: @obo_client
      end
    end

    "#" <> funding_type <> "_#" <> funding_mode
  end

  defp no_compliance_relationship?(context) do
    context.account.non_client? && (!context.house_account || context.house_account.non_client?)
  end

  defp nested_payments_with_collections?(context) do
    is_regulated = if context.house_account, do: context.house_account.regulated?, else: context.account.regulated?

    is_regulated && context.account.client? &&
      (context.sender.not_account_holder? || context.sender.approved_funding_partner?)
  end
end
