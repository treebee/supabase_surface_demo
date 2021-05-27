defmodule SupabaseSurfaceDemo.Accounts do
  alias SupabaseSurfaceDemo.Profile

  def get_user!(access_token) do
    {:ok, user} = Supabase.auth() |> GoTrue.get_user(access_token)
    user
  end

  def get_profile!(access_token, user_id) do
    case get_profile(access_token, user_id) do
      {:ok, profile} -> profile
      {:error, error} -> raise error
    end
  end

  def get_profile(access_token, user_id) do
    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("profiles")
         |> Postgrestex.eq("user_id", user_id)
         |> Postgrestex.call()
         |> Supabase.json(keys: :atoms) do
      %{status: 200, body: [profile]} -> {:ok, profile}
      %{status: 200, body: []} -> {:error, :no_result}
      %{body: %{"error" => error}} -> {:error, error}
    end
  end

  def create_profile(access_token, user) do
    meta = Map.get(user, "user_metadata", %{})
    username = meta |> Map.get("full_name")
    avatar_url = meta |> Map.get("avatar_url")

    attrs = %{
      "username" => username,
      "user_id" => user["id"],
      "email" => user["email"],
      "avatar_url" => avatar_url
    }

    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("profiles")
         |> Postgrestex.insert(attrs)
         |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
         |> Postgrestex.call()
         |> Supabase.json(keys: :atoms) do
      %{status: 201, body: [profile]} -> {:ok, profile}
      _error -> {:error, "Couldn't create profile"}
    end
  end

  def update_profile(access_token, user_id, profile, params) do
    changeset = Profile.changeset(profile, params)

    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("profiles")
         |> Postgrestex.eq("user_id", user_id)
         |> Postgrestex.update(changeset.changes)
         |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
         |> Postgrestex.call()
         |> Supabase.json(keys: :atoms) do
      %{body: [profile]} -> {:ok, profile}
      _ -> {:error, "Error updating profile"}
    end
  end
end
