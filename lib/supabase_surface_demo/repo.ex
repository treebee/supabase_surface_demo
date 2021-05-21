defmodule SupabaseSurfaceDemo.Repo do
  use Ecto.Repo,
    otp_app: :supabase_surface_demo,
    adapter: Ecto.Adapters.Postgres
end
