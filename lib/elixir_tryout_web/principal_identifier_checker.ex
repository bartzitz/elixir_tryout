defmodule ElixirTryoutWeb.PrincipalIdentifierChecker do
  import Plug.Conn
  # import ElixirTryout.WebAdaptors.BaseAdaptor

  def init(opts), do: opts

  def call(conn, _opts) do
    conn |> check_principal_identifier_presence()
  end

  defp check_principal_identifier_presence(conn) do
    principal_identifier = conn.query_params["principal_identifier"]

    unless principal_identifier, do: send_resp(conn, :forbidden, "User not authorized. Principal identifier is missing")

    #send_request_to_crm_to_check_if_contact_authorized(principal_identifier["effective_account_id]")

    conn
  end
end
