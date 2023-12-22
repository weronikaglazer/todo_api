import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

config :my_app, MyApp.Repo,
  username: "weronikaglazer",
  password: "weronikaglazer",
  hostname: "my_postgres",
  database: "myapp_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :my_app, MyAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "cW0Tt7r6CsALJF23/WYdfi4DFxGEtONYQN56vp3F9HiZL8nS6zJa3mTUX8QP8/Mj",
  server: false

# In test we don't send emails.
config :my_app, MyApp.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

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
