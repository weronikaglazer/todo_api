# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.


# General application configuration
import Config

config :my_app,
  ecto_repos: [MyApp.Repo],
  generators: [timestamp_type: :utc_datetime]



# Configures the endpoint
config :my_app, MyAppWeb.Endpoint,
  url: [host: "localhost", port: 4000],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: MyAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MyApp.PubSub,
  live_view: [signing_salt: "XTGzbm4q"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Elasticsearch
config :my_app, MyApp.ElasticsearchCluster,
  url: "http://my_elasticsearch:9200",
  username: "username",
  password: "password",
  api: Elasticsearch.API.HTTP,
  json_library: Jason,
  indexes: %{
    tasks: %{
      settings: "priv/elasticsearch/tasks.json",
      store: MyApp.ElasticsearchStore,
      sources: [MyApp.Task],
      bulk_page_size: 5000,
      bulk_wait_interval: 15_000, # 15 seconds
      bulk_action: "create"
    }
  }

config :my_app, MyApp.ElasticsearchCluster,
  default_options: [
    timeout: 5_000,
    recv_timeout: 5_000,
    hackney: [pool: :pool_name]
  ]

# Configures Guardian

config :my_app, MyAppWeb.Auth.Guardian,
  issuer: "my_app",
  secret_key: "pF00RupCvZyqrxhSX/xbPXyocIQgS5YLzZX1CsnJjwxATmJareFgWjYW5q3ddTA0"


# Configures GuardianDB

config :guardian, Guardian.DB,
  repo: MyApp.Repo,
  schema_name: "guardian_tokens",
  token_types: ["access"],
  sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
