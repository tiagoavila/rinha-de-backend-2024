defmodule Rinha.Customer do
  use Ecto.Schema

  @customer_ids MapSet.new([1, 2, 3, 4, 5])

  @primary_key {:id, :integer, autogenerate: false}
  schema "cliente" do
    field(:limite, :integer)
    field(:saldo, :integer)
  end

  def handle_transaction(transaction_body, customer_id) do
    Poison.decode!(transaction_body) 
    |> validate_required_fields()
    |> validate_transaction(customer_id)
  end

  defp validate_required_fields(transaction) do
    cond do
      Map.has_key?(transaction, "descricao") && Map.has_key?(transaction, "tipo") && Map.has_key?(transaction, "valor") -> transaction
      true -> {:error, "descricao, tipo e valor são campos obrigatórios"}
    end
  end

  defp validate_transaction({:error, _} = required_fields_validation_result, _), do: required_fields_validation_result

  defp validate_transaction(%{"descricao" => description, "tipo" => type, "valor" => value} = transaction, customer_id) do
    cond do
      type != "c" && type != "d" -> {:error, "Tipo de transação inválido"}
      value <= 0 || value |> Integer.to_string() |> String.slice(-2..-1) != "00" -> {:error, "Valor deve ser um número inteiro positivo"}
      description |> validate_description_length() -> {:error, "Descrição deve ter entre 1 e 10 caracteres"}
      !MapSet.member?(@customer_ids, customer_id) -> {:client_not_found, "Cliente não encontrado"}
      true -> {:ok, transaction}
    end
  end

  defp validate_description_length(description) do
    length = String.length(description)
    length < 1 || length > 10
  end
end
