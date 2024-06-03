defmodule Rinha.Customer do
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}
  schema "customer" do
    field(:limit, :integer)
    field(:initial_balance, :integer)
  end
end
