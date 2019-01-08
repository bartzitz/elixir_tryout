# @todo replace with a real model
defmodule ElixirTryout.FundsOriginator do
  defstruct [:free_text, :name, :address, :account_id, :status, :classification, :account_details]

  def validate(self_struct) do
    # @todo
    self_struct
  end

  def to_map(self_struct, _opts \\ {}) do
    %{
      classified?: classified?(self_struct),
      account_holder?: account_holder?(self_struct),
      not_account_holder?: not_account_holder?(self_struct),
      approved_funding_partner?: approved_funding_partner?(self_struct),
      unknown?: unknown?(self_struct),
      screening_required?: screening_required?(self_struct)
    }
  end

  def classified?(self_struct) do
    self_struct.classification != "unknown"
  end

  def account_holder?(self_struct) do
    self_struct.classification == "account_holder"
  end

  def not_account_holder?(self_struct) do
    self_struct.classification == "not_account_holder"
  end

  def approved_funding_partner?(self_struct) do
    self_struct.classification == "approved_funding_partner"
  end

  def unknown?(self_struct) do
    self_struct.classification == "unknown"
  end

  def screening_required?(self_struct) do
    Enum.member?(["unchecked", "always_check", "compliance_review_required"], self_struct.status) && !approved_funding_partner?(self_struct)
  end
end
