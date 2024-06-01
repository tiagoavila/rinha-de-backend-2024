defmodule Rinha.Repo do
    use Ecto.Repo,
    otp_app: :rinha_2024,
    adapter: Ecto.Adapters.Postgres
end