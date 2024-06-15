defmodule Rinha.Customer do
  use Ecto.Schema
  import Ecto.Query

  @customer_ids MapSet.new([1, 2, 3, 4, 5])

  @primary_key {:id, :integer, autogenerate: false}
  schema "cliente" do
    field(:limite, :integer)
    field(:saldo, :integer)
    has_many(:transacao, Rinha.Transaction, foreign_key: :cliente_id)
  end

  def update_balance(transaction_body, customer_id) do
    transaction_body
    |> validate_required_fields()
    |> validate_transaction(customer_id)
    |> process_transaction(customer_id)
  end

  def get_statement(customer_id) do
    case MapSet.member?(@customer_ids, customer_id) do
      true -> {:ok, do_get_statement(customer_id)}
      false -> {:client_not_found, "Cliente não encontrado"}
    end
  end

  defp validate_required_fields(transaction) do
    cond do
      Map.has_key?(transaction, "descricao") && Map.has_key?(transaction, "tipo") &&
          Map.has_key?(transaction, "valor") ->
        transaction

      true ->
        {:error, "descricao, tipo e valor são campos obrigatórios"}
    end
  end

  defp validate_transaction({:error, _} = required_fields_validation_result, _),
    do: required_fields_validation_result

  defp validate_transaction(
         %{"descricao" => description, "tipo" => type, "valor" => value} = transaction,
         customer_id
       ) do
    cond do
      type != "c" && type != "d" ->
        {:error, "Tipo de transação inválido"}

      value <= 0 || value |> Integer.to_string() |> String.slice(-2..-1) != "00" ->
        {:error, "Valor deve ser um número inteiro positivo"}

      description |> validate_description_length() ->
        {:error, "Descrição deve ter entre 1 e 10 caracteres"}

      !MapSet.member?(@customer_ids, customer_id) ->
        {:client_not_found, "Cliente não encontrado"}

      true ->
        {:ok, transaction}
    end
  end

  defp validate_description_length(description) do
    length = String.length(description)
    length < 1 || length > 10
  end

  defp process_transaction({:ok, %{"tipo" => "c"} = transaction}, customer_id) do
    customer = Rinha.Repo.get(Rinha.Customer, customer_id)
    new_balance = transaction["valor"] + customer.saldo

    save_transaction_to_db_async(customer, transaction)
    save_new_balance(customer, new_balance)
  end

  defp process_transaction({:ok, %{"tipo" => "d"} = transaction}, customer_id) do
    customer = Rinha.Repo.get(Rinha.Customer, customer_id)
    new_balance = customer.saldo - transaction["valor"]

    cond do
      new_balance < -customer.limite ->
        {:error, "Saldo inconsistente"}

      true ->
        save_transaction_to_db_async(customer, transaction)
        save_new_balance(customer, new_balance)
    end
  end

  defp process_transaction(error, _), do: error

  defp save_new_balance(customer, new_balance) do
    changeset = Ecto.Changeset.change(customer, saldo: new_balance)

    case Rinha.Repo.update(changeset) do
      {:ok, updated_customer} ->
        {:ok, %{"limite" => updated_customer.limite, "saldo" => new_balance}}

      error ->
        error
    end
  end

  defp save_transaction_to_db_async(customer, transaction) do
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

  defp do_get_statement(customer_id) do
    query =
      from(c in Rinha.Customer,
        where: c.id == ^customer_id
      )

    customer = Rinha.Repo.one(query)

    query =
      from(t in Rinha.Transaction,
        where: t.cliente_id == ^customer_id,
        limit: 10,
        order_by: [desc: :realizada_em]
      )

    transactions = Rinha.Repo.all(query)

    %{
      "saldo" => %{
        "total" => customer.saldo,
        "limite" => customer.limite,
        "data_extrato" => NaiveDateTime.to_iso8601(NaiveDateTime.utc_now())
      },
      "ultimas_transacoes" => transactions |> Enum.map(fn transaction ->
        %{
          "descricao" => transaction.descricao,
          "tipo" => transaction.tipo,
          "valor" => transaction.valor,
          "realizada_em" => NaiveDateTime.to_iso8601(transaction.realizada_em)
        }
      end)
    }
  end
end
