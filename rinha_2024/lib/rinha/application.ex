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

    children = [
      # Starts a worker by calling: Rinha.Worker.start_link(arg)
      # {Rinha.Worker, arg}
      Rinha.Repo,
      %{
        id: :elli,
        start: {:elli, :start_link, [[callback: ElliCallback, port: 4000]]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
