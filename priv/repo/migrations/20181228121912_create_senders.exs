defmodule ElixirTryout.Repo.Migrations.CreateSenders do
  use Ecto.Migration

  def change do
    create table(:senders) do
      add :status, :string
      add :classification, :string

      timestamps()
    end

  end
end
