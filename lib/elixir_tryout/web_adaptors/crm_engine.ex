defmodule ElixirTryout.WebAdaptors.CrmEngine do
  import ElixirTryout.WebAdaptors.BaseAdaptor

  def find_accounts(params \\ []) do
    get("crm/v2/accounts/account/find", params)
  end
end
