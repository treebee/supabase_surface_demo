defmodule SupabaseSurfaceDemo.Repo.Migrations.UserClicks do
  use Ecto.Migration

  def change do
    create table(:user_clicks) do
      add :user_id, :uuid, null: false
    end


    # XXX for some reason this doesn't work anymore, fails with
    # ERROR 42501 (insufficient_privilege) must be owner of publication supabase_realtime
    # But it worked in the 'init' migration ?!
    # execute("alter publication supabase_realtime add table user_clicks;")
  end
end
