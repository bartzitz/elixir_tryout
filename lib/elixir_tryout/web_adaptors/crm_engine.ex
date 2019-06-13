defmodule ElixirTryout.WebAdaptors.CrmEngine do
  import ElixirTryout.WebAdaptors.BaseAdaptor

  @host "http://localhost:38081/"

  def find_accounts(params \\ %{}) do
    get("#{@host}/crm/v2/accounts/account/find", params)
  end

  def get_account_classification(account_id) do
    get("#{@host}/crm/v2/accounts/:account_id/account_classification", %{account_id: account_id})
  end

  def create_virtual_account(params \\ %{}) do
    post("#{@host}/crm/virtual_accounts/internal/create", params)
  end
end
