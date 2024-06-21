defmodule Rinha.Transaction do
  use Ecto.Schema

  schema "transacao" do
    field(:descricao, :string)
    field(:tipo, :string)
    field(:valor, :integer)
    field(:realizada_em, :naive_datetime)
    belongs_to(:cliente, Rinha.Customer)
  end

  def save_transaction_to_db_async(customer, transaction) do
    Task.start(fn ->
      Ecto.build_assoc(customer, :transacao, %{
        descricao: transaction["descricao"],
        tipo: transaction["tipo"],
        valor: transaction["valor"],
        realizada_em: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      })
      |> Rinha.Repo.insert()
    end)
  end
end
