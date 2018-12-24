defmodule ElixirTryoutWeb.TransactionsControllerTest do
  use ElixirTryoutWeb.ConnCase

  describe "index/0" do
    test "responds with empty array when no transactions", %{conn: conn} do
      response =
        conn
        |> get("/api/transactions")
        |> json_response(200)

      assert response == []
    end

    test "responds with list of transactions", %{conn: conn} do
      ElixirTryout.Repo.insert(%ElixirTryout.Transaction{amount: 120, currency: "USD"})

      response =
        conn
        |> get("/api/transactions")
        |> json_response(200)

      expected = [
        %{"amount" => "120", "currency" => "USD"}
      ]

      assert response == expected
    end
  end
end
