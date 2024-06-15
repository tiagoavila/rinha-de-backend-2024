defmodule ElliCallback do
  @behaviour :elli_handler

  alias Rinha.Customer

  @impl true
  def handle(req, _args) do
    do_handle(:elli_request.method(req), :elli_request.path(req), req)
  end

  defp do_handle(:GET, [], _req), do: {:ok, "Welcome! I'm running on Docker. I'm awesome!!!"}

  defp do_handle(:POST, ["clientes", customer_id, "transacoes"], req) do
    customer_id = String.to_integer(customer_id)

    case :elli_request.body(req) |> Poison.decode!() |> Customer.update_balance(customer_id) do
      {:ok, transaction} -> return_ok_response(transaction)
      {:error, message} -> return_bad_request(message)
      {:client_not_found, message} -> return_not_found(message)
    end
  end

  defp do_handle(:GET, ["clientes", customer_id, "extrato"], _req) do
    customer_id = String.to_integer(customer_id)

    case Customer.get_statement(customer_id) do
      {:ok, statement} -> return_ok_response(statement)
      {:client_not_found, message} -> return_not_found(message)
    end
  end

  @impl true
  def handle_event(_event, _data, _args), do: :ok

  defp return_ok_response(response_entity),
    do: {:ok, [{"Content-Type", "application/json"}], response_entity |> Poison.encode!()}

  defp return_bad_request(error_message),
    do:
      {400, [{"Content-Type", "application/json"}],
       %{"error" => error_message} |> Poison.encode!()}

  defp return_not_found(error_message),
    do:
      {404, [{"Content-Type", "application/json"}],
       %{"error" => error_message} |> Poison.encode!()}
end
