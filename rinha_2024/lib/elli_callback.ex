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

    case :elli_request.body(req) |> Customer.add_transaction(customer_id) do
      {:ok, transaction} -> transaction |> return_ok_response()
      {:error, message} -> message |> return_error_message_response(400)
      {:client_not_found, message} -> message |> return_error_message_response(404)
    end
  end

  @impl true
  def handle_event(_event, _data, _args), do: :ok

  defp return_ok_response(response_entity),
    do: {:ok, [{"Content-Type", "application/json"}], response_entity |> Poison.encode!()}

  defp return_error_message_response(error_message, response_code),
    do:
      {response_code, [{"Content-Type", "application/json"}],
       %{"error" => error_message} |> Poison.encode!()}
end
