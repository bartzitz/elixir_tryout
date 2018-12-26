defmodule ElixirTryoutWeb.TransactionsController do
  use ElixirTryoutWeb, :controller

  def index(conn, _) do
    transactions = ElixirTryout.Repo.all(ElixirTryout.Transaction)

    json(conn, transactions)
  end

  def show(conn, %{"id" => id}) do
    transaction = ElixirTryout.Repo.get(ElixirTryout.Transaction, String.to_integer(id))

    if transaction do
      json conn |> put_status(:ok), transaction
    else
      json(conn |> put_status(:not_found),
        %{errors: ["invalid transaction"] })
    end
  end

  def create(conn, params) do
    changeset = ElixirTryout.Transaction.changeset(%ElixirTryout.Transaction{}, params)
    {_, res} = ElixirTryout.Repo.insert(changeset)

    json(conn, %{status: "ok"})
  end

  def update(conn, %{"id" => id} = params) do
    transaction = ElixirTryout.Repo.get(ElixirTryout.Transaction, String.to_integer(id))

    if transaction do
      changeset = ElixirTryout.Transaction.changeset(transaction, params)

      case ElixirTryout.Repo.update(changeset) do
        {:ok, transaction} ->
          json conn |> put_status(:ok), transaction
        {:error, result} ->

          json conn |> put_status(:bad_request),
               %{errors: result.errors }
      end
    else
      json(conn |> put_status(:not_found),
           %{errors: ["invalid transaction"] })
    end
  end
end