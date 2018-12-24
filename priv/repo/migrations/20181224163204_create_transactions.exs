defmodule ElixirTryout.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :decimal
      add :currency, :string

      timestamps()
    end

  end
end
