defmodule ElixirTryout.Repo.Migrations.AddSenderIdToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :sender_id, :integer
    end
  end
end
