defmodule ElixirTryout.Sender do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:status, :classification]}

  schema "transactions" do
    field :status, :string
    field :classification, :string

    timestamps()
  end

  def changeset(sender, attrs) do
    sender
    |> cast(attrs, [:status, :classification])
  end

  def is_classified(sender), do: sender.classification != "unknown"
  def is_account_holder(sender), do: sender.classification == "account_holder"
  def is_not_account_holder(sender), do: sender.classification == "not_account_holder"
  def is_approved_funding_partner(sender), do: sender.classification == "approved_funding_partner"
  def is_unknown(sender), do: sender.classification == "unknown"

  def is_screening_required(sender) do
    Enum.member?(["unchecked", "always_check", "compliance_review_required"], sender.status) && !ElixirTryout.Sender.is_approved_funding_partner(sender)
  end
end
