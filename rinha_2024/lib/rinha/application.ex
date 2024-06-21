defmodule Rinha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ElliCallback
  alias Rinha.ReleaseTasks

  @impl true
  def start(_type, _args) do
    ReleaseTasks.migrate()
    http_port = String.to_integer(System.fetch_env!("HTTP_SERVER_PORT") || "4000")

    children = [
      # Starts a worker by calling: Rinha.Worker.start_link(arg)
      # {Rinha.Worker, arg}
      Rinha.Repo,
      %{
        id: :elli,
        start: {:elli, :start_link, [[callback: ElliCallback, port: http_port]]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
