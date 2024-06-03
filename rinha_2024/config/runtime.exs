import Config

# if config_env() == :prod do
#   config :rinha_2024, Rinha.Repo,
#     database: "rinha_db",
#     username: "postgres",
#     password: "pass",
#     hostname: "postgres_database"
# end

#   pool_size: System.fetch_env!("DB_CONNS") |> String.to_integer()

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :rinha_2024, Rinha.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6
end
