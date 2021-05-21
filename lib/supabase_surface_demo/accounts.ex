defmodule SupabaseSurfaceDemo.Accounts do
  alias SupabaseSurfaceDemo.Profile

  def get_user!(access_token) do
    {:ok, user} = Supabase.auth() |> GoTrue.get_user(access_token)
    user
  end

  def get_profile(access_token, user_id) do
    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("profiles")
         |> Postgrestex.eq("user_id", user_id)
         |> Postgrestex.call()
         |> Supabase.json(keys: :atoms) do
      %{status: 200, body: [profile]} -> {:ok, profile}
      %{status: 200, body: []} -> {:error, :no_result}
      _ -> raise "Failed fetching profile"
    end
  end

  def create_profile(access_token, user) do
    username = Map.get(user, "user_metadata", %{}) |> Map.get("full_name")
    attrs = %{"username" => username, "user_id" => user["id"], "email" => user["email"]}

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
end
