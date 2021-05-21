# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :supabase_surface_demo,
  ecto_repos: [SupabaseSurfaceDemo.Repo]

config :supabase_surface_demo, SupabaseSurfaceDemo.Repo,
  database: System.get_env("POSTGRES_DB", "supabase_surface_demo_dev"),
  username: "postgres",
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost")

# Configures the endpoint
config :supabase_surface_demo, SupabaseSurfaceDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nG7gKvqoBOejWXwF0W4fBCEWrXn4NzAPBZVfiWCRwHRPGlNXfUa3gj+eea6ghVOU",
  render_errors: [view: SupabaseSurfaceDemoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SupabaseSurfaceDemo.PubSub,
  live_view: [signing_salt: "HjBtVHIj"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :supabase,
  base_url: System.get_env("SUPABASE_URL"),
  api_key: System.get_env("SUPABASE_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
