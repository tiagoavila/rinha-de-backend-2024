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
    validation_result = :elli_request.body(req) |> Customer.handle_transaction(customer_id) |> IO.inspect(label: "validation_result") 
    case validation_result do
      {:error, message} -> {400, message}
      {:client_not_found, message} -> {404, message}
      {:ok, transaction} -> {:ok, "post to id #{customer_id}"} 
    end
  end

  @impl true
  def handle_event(_event, _data, _args), do: :ok
end
