defmodule SenderScreening.Status do
  alias ElixirTryout.Transaction

  def calculate(transaction, funds_originator) do
    cond do
      Transaction.prohibited?(transaction) -> prohibited_label()
      Treansaction.collections?(transaction) && FundsOriginator.screening_required?(funds_originator) -> required_label()
      Treansaction.collections?(transaction) && !FundsOriginator.screening_required?(funds_originator) -> not_required_label()
      true -> unknown_label()
    end
  end

  def prohibited_label, do: "prohibited"

  def required_label, do: "required"

  def not_required_label, do: "not_required"

  def unknown_label, do: "unknown"
end
