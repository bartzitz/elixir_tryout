defmodule ElixirTryout.WebAdaptors.BaseAdaptor do
  def post(host, path, options) do
    body = Jason.encode!(options)

    "#{host}/#{path}?#{URI.encode_query(crm_principle_identifier())}"
    |> HTTPoison.post!(body, headers)
    |> evaluate_response()
  end

  def get(host, path, options) do
    params = Map.merge(options, crm_principle_identifier())

    "#{host}/#{path}"
    |> HTTPoison.get!(headers, params: params)
    |> evaluate_response()
  end

  defp crm_principle_identifier do
    %{
      "principal_identifier[contact_id]" => "58e78791-e0e5-012c-2dee-001e52f3c730",
      "principal_identifier[account_id]" => "2090939e-b2f7-3f2b-1363-4d235b3f58af",
      "principal_identifier[effective_contact_id]" => "58e78791-e0e5-012c-2dee-001e52f3c730",
      "principal_identifier[effective_account_id]" => "2090939e-b2f7-3f2b-1363-4d235b3f58af"
    }
  end

  defp headers do
    [{"Content-type", "application/json"}]
  end

  defp evaluate_response(response) do
    case Jason.decode!(response.body) do
      %{"status" => "success", "data" => data} ->
        %{"status" => 200, "data" => data}
      %{"status" => "error", "message" => message} ->
        %{"status" => 400, "message" => message}
      %{"status" => "failed", "reason" => reason} ->
        %{"status" => 400, "reason" => reason}
    end
  end
end