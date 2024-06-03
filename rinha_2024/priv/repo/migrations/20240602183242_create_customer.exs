defmodule Rinha.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:customer, primary_key: false) do
      add :id, :smallint, primary_key: true
      add :limit, :integer
      add :initial_balance, :integer
    end
  end
end
