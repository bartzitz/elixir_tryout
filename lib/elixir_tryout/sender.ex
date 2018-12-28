defmodule ElixirTryout.Sender do
  use Ecto.Schema
  import Ecto.Changeset


  schema "senders" do
    field :classification, :string,  default: "unknown"
    field :status, :string, default: "unchecked"

    has_many :transactions, Transaction

    timestamps()
  end

  @doc false
  def changeset(sender, attrs) do
    sender
    |> cast(attrs, [:status, :classification])
    |> validate_required([:status, :classification])
  end

  def
end
