defmodule ElixirTryout.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:amount, :currency]}

  schema "transactions" do
    field :amount, :decimal
    field :currency, :string
    field :funding_type, :string
    field :funding_mode, :string

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :currency, :funding_type, :funding_mode])
    |> validate_required([:amount, :currency])
  end
end
