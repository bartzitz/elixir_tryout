defmodule ElixirTryoutWeb.TransactionsControllerTest do
  use ElixirTryoutWeb.ConnCase

  describe "index/2" do
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

  describe "show/2" do
    test "responds with not found error when no transaction", %{conn: conn} do
      response =
        conn
        |> get("/api/transactions/1")
        |> json_response(404)

      assert response == %{"errors" => ["invalid transaction"]}
    end

    test "responds with transaction if exist", %{conn: conn} do
      {_, transaction} = ElixirTryout.Repo.insert(%ElixirTryout.Transaction{amount: 120, currency: "USD"})

      response =
        conn
        |> get("/api/transactions/#{transaction.id}")
        |> json_response(200)

      expected = %{"amount" => "120", "currency" => "USD"}

      assert response == expected
    end
  end

  describe "update/2" do
    test "responds with not found error when no transaction", %{conn: conn} do
      response =
        conn
        |> put("/api/transactions/1")
        |> json_response(404)

      assert response == %{"errors" => ["invalid transaction"]}
    end

    test "responds with bad request error when no transaction", %{conn: conn} do
      {_, transaction} = ElixirTryout.Repo.insert(%ElixirTryout.Transaction{amount: 120, currency: "USD"})
      params = %{amount: ""}

      response =
        conn
        |> put("/api/transactions/#{transaction.id}", params)
        |> json_response(400)

      assert response == %{"errors" => [amount: {"can't be blank", [validation: :required]}]}
    end

    test "responds with transaction if exist", %{conn: conn} do
      {_, transaction} = ElixirTryout.Repo.insert(%ElixirTryout.Transaction{amount: 120, currency: "USD"})
      params = %{amount: 101}

      response =
        conn
        |> put("/api/transactions/#{transaction.id}", params)
        |> json_response(200)

      expected = %{"amount" => "101", "currency" => "USD"}

      assert response == expected
    end
  end
end
