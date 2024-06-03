defmodule ElliCallback do
  @behaviour :elli_handler

  @impl true
  def handle(req, _args) do
    do_handle(:elli_request.method(req), :elli_request.path(req), req)
  end

  defp do_handle(:GET, [], _req), do: {:ok, "Welcome! I'm running on Docker. I'm awesome!!!"}

  @impl true
  def handle_event(_event, _data, _args), do: :ok
end
