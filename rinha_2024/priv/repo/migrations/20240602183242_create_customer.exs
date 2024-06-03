defmodule Rinha.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:cliente, primary_key: false) do
      add :id, :smallint, primary_key: true
      add :limite, :integer
      add :saldo, :integer
    end

    execute "INSERT INTO public.cliente(id, limite, saldo) VALUES (1, 100000, 0);"
    execute "INSERT INTO public.cliente(id, limite, saldo) VALUES (2, 80000, 0);"
    execute "INSERT INTO public.cliente(id, limite, saldo) VALUES (3, 1000000, 0);"
    execute "INSERT INTO public.cliente(id, limite, saldo) VALUES (4, 10000000, 0);"
    execute "INSERT INTO public.cliente(id, limite, saldo) VALUES (5, 500000, 0);"
  end
end
