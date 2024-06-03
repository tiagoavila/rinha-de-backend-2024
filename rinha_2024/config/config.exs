import Config

config :rinha_2024, :ecto_repos, [Rinha.Repo]

import_config "#{Mix.env()}.exs"
