defmodule SupabaseSurfaceDemo.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table("profiles", primary_key: false) do
      add :user_id, :uuid, primary_key: true, null: false
      add :username, :text
      add :email, :text, null: false
      add :website, :text
      add :avatar_url, :text
    end

    flush()

    execute("ALTER TABLE profiles enable row level security")

    execute("""
    create policy "Public profiles are viewable by everyone."
    on profiles for select
    using ( true );
    """)

    execute("""
    create policy "Users can insert their own profile."
    on profiles for insert
    with check ( auth.uid() = user_id );
    """)

    execute("""
    create policy "Users can update own profile."
    on profiles for update
    using ( auth.uid() = user_id );
    """)

    execute("drop publication if exists supabase_realtime;")
    execute("create publication supabase_realtime;")

    execute("alter publication supabase_realtime add table profiles;")

    execute("""
    insert into storage.buckets (id, name)
    values ('avatars', 'avatars');
    """)

  end
end
