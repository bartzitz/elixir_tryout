defmodule ElixirTryoutWeb.TransactionsController do
  use ElixirTryoutWeb, :controller

  import ElixirTryoutWeb.ErrorHelpers, only: [translate_error: 1]

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

    case ElixirTryout.Repo.insert(changeset) do
      {:ok, result} -> conn |> put_status(:ok) |> json(result)
      {:error, result} -> conn |> put_status(:bad_request) |> json(%{errors: Ecto.Changeset.traverse_errors(result, &translate_error/1)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    transaction = ElixirTryout.Repo.get(ElixirTryout.Transaction, String.to_integer(id))

    if transaction do
      changeset = ElixirTryout.Transaction.changeset(transaction, params)

      case ElixirTryout.Repo.update(changeset) do
        {:ok, result} ->
          json conn |> put_status(:ok), result
        {:error, result} ->
          json conn |> put_status(:bad_request),
            %{errors: Ecto.Changeset.traverse_errors(result, &translate_error/1)}
      end
    else
      json(conn |> put_status(:not_found),
           %{errors: ["invalid transaction"] })
    end
  end
end