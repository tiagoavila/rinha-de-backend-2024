defmodule Rinha.Customer do
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}
  schema "cliente" do
    field(:limite, :integer)
    field(:saldo, :integer)
  end
end
