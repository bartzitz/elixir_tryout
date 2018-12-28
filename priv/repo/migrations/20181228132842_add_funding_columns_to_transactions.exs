defmodule ElixirTryout.Repo.Migrations.AddFundingColumnsToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :funding_type, :string
      add :funding_mode, :string
    end
  end
end
