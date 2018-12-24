defmodule ElixirTryout.Transaction do
  use Ecto.Schema
  import Ecto.Changeset


  schema "transactions" do
    field :amount, :decimal
    field :currency, :string

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :currency])
    |> validate_required([:amount, :currency])
  end
end
