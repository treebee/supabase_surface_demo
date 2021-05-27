defmodule SupabaseSurfaceDemo.Repo.Migrations.UserClicks do
  use Ecto.Migration

  def change do
    create table(:user_clicks) do
      add :user_id, :uuid, null: false
    end

    execute("alter publication supabase_realtime add table user_clicks;")
  end
end
