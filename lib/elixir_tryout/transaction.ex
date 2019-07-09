defmodule ElixirTryout.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:amount, :currency]}

  schema "transactions" do
    field :amount, :decimal
    field :currency, :string

    belongs_to :sender, Sender

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :currency])
    |> validate_required([:amount, :currency])
  end
end
