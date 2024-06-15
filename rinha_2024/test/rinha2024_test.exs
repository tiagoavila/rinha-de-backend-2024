defmodule Rinha2024Test do
  use ExUnit.Case
  doctest Rinha.Customer

  setup do
    customer_id = 1
    customer = Rinha.Repo.get(Rinha.Customer, customer_id)
    {:ok, customer: customer, customer_id: customer_id}
  end

  test "Test Update Balance with Credit Transaction", %{customer: customer, customer_id: customer_id} do
    new_balance = customer.saldo + 100

    transaction_body =
      %{
        "descricao" => "credit",
        "tipo" => "c",
        "valor" => 100
      }

    updated_balance_response = Rinha.Customer.update_balance(transaction_body, customer_id)
    assert {:ok, %{"limite" => 100_000, "saldo" => new_balance}} == updated_balance_response
  end

  test "Test Update Balance with Debit Transaction", %{customer: customer, customer_id: customer_id} do
    new_balance = customer.saldo - 100

    transaction_body =
      %{
        "descricao" => "debit",
        "tipo" => "d",
        "valor" => 100
      }

    updated_balance_response = Rinha.Customer.update_balance(transaction_body, customer_id)
    assert {:ok, %{"limite" => 100_000, "saldo" => new_balance}} == updated_balance_response
  end
end
