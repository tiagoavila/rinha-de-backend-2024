defmodule Rinha.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transacao) do
      add :cliente_id, references(:cliente, on_delete: :nothing, type: :smallint)
      add :descricao, :string, size: 10
      add :tipo, :char
      add :valor, :integer
      add :realizada_em, :naive_datetime
    end
  end
end
