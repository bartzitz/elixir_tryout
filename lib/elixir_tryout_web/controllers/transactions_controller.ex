defmodule ElixirTryoutWeb.TransactionsController do
  use ElixirTryoutWeb, :controller

  def index(conn, _) do
    transactions = ElixirTryout.Repo.all(ElixirTryout.Transaction)

    json(conn, transactions)
  end

  def create(conn, params) do
    changeset = ElixirTryout.Transaction.changeset(%ElixirTryout.Transaction{}, params)
    {_, res} = ElixirTryout.Repo.insert(changeset)

    json(conn, %{status: "ok"})
  end
end