defmodule ElixirTryoutWeb.RootController do
  use ElixirTryoutWeb, :controller

  def index(conn, _params) do
    json(conn, %{test: "value"})
  end

  def index_html(conn, _params) do
    transactions = [
      %{
        client: "Azimo ltd",
        client_enabled: true,
        sender: "Random guy",
        sender_status: "Unknown",
        sender_css: "badge-secondary",
        account: "Arkea payment",
        amount: "1005000.00",
        currency: "EUR",
        value_date: "11 Apr 19",
        created_on: "11 Apr 19"
      },
      %{
        client: "Another client",
        client_enabled: false,
        sender: "Other guy",
        sender_status: "Unknown",
        sender_css: "badge-secondary",
        account: "CFSB client",
        amount: "300.00",
        currency: "USD",
        value_date: "11 Apr 19",
        created_on: "11 Apr 19"
      }
    ]

    item = %{
      client: "Company x",
      client_enabled: true,
      sender: "Proper company",
      sender_status: "Approved",
      sender_css: "badge-success",
      account: "Barclays client",
      amount: "3200.00",
      currency: "GBP",
      value_date: "11 Apr 19",
      created_on: "11 Apr 19"
    }

    transactions = (1..10) |> Enum.map(fn _ -> item end) |> Enum.into(transactions)

    render(conn, "index.html", transactions: transactions)
  end
end