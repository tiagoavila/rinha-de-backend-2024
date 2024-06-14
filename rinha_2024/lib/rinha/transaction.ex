defmodule Rinha.Transaction do
    use Ecto.Schema

    schema "transacao" do
        field(:descricao, :string)
        field(:tipo, :string)
        field(:valor, :integer)
        belongs_to(:customer, Rinha.Customer)

        timestamps()
    end
end