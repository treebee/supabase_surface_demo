import Config

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  host = System.get_env("DEV_HOST", "#{app_name}.fly.dev")

  config :supabase_surface_demo, SupabaseSurfaceDemoWeb.Endpoint,
    server: true,
    url: [host: host, port: 4000],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      # IMPORTANT: support IPv6 addresses
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :supabase_surface_demo, SupabaseSurfaceDemo.Repo,
    url: database_url,
    # IMPORTANT when using postgres db on fly but we are using Supabase
    # socket_options: [:inet6],
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  config :supabase,
    base_url: System.get_env("SUPABASE_URL"),
    api_key: System.get_env("SUPABASE_KEY"
end
