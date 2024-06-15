defmodule Rinha.Transaction do
    use Ecto.Schema

    schema "transacao" do
        field(:descricao, :string)
        field(:tipo, :string)
        field(:valor, :integer)
        field(:realizada_em, :naive_datetime)
        belongs_to(:cliente, Rinha.Customer)
    end
end
