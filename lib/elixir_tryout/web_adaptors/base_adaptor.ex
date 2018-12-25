defmodule ElixirTryout.WebAdaptors.BaseAdaptor do
  def post(path, params) do
    url = "#{crm_host()}#{path}?#{crm_principle_identifier()}"
    body = Jason.encode!(
      [
        %{param: params}
      ]
    )

    response = HTTPoison.post!(url, body, [])
    Jason.decode!(response.body, keys: :atoms)
  end

  def get(path, params) do
    url = "#{crm_host()}#{path}?#{crm_principle_identifier()}"

    response = HTTPoison.get!(url, [], params: params)
    Jason.decode!(response.body, keys: :atoms)
  end

  defp crm_host do
    "http://localhost:38081/"
  end

  defp crm_principle_identifier do
    URI.encode_query(
      %{
        "principal_identifier[contact_id]" => "58e78791-e0e5-012c-2dee-001e52f3c730",
        "principal_identifier[account_id]" => "2090939e-b2f7-3f2b-1363-4d235b3f58af",
        "principal_identifier[effective_contact_id]" => "58e78791-e0e5-012c-2dee-001e52f3c730",
        "principal_identifier[effective_account_id]" => "2090939e-b2f7-3f2b-1363-4d235b3f58af"
      }
    )
  end
end
