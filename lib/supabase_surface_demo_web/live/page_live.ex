defmodule SupabaseSurfaceDemoWeb.PageLive do
  use Surface.LiveView

  alias SupabaseSurfaceDemoWeb.Components.Auth
  alias SupabaseSurfaceDemoWeb.Components.Profile

  data user, :map, default: nil
  data access_token, :string, default: nil
  data refresh_token, :string, default: nil

  @impl true
  def mount(_params, %{"access_token" => access_token, "refresh_token" => refresh_token}, socket) do
    socket =
      with {:ok, socket, access_token} <-
             check_token_expiration(access_token, refresh_token, socket),
           {:ok, socket, user} <- fetch_user(access_token, socket),
           {:ok, profile} <- fetch_profile(access_token, user, socket) do
        assign(socket, profile: profile)
      else
        {:error, socket} ->
          socket
      end

    assign(socket, access_token: access_token, refresh_token: refresh_token)

    {:ok, socket}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <Auth
        :if={{ is_nil(@access_token) }}
        id="supabase-auth"
        redirect_url="/"
        class="md:max-w-lg mx-auto"
        magic_link={{ true }}
        providers={{ ["github", "google"] }}
        />
      <div :if={{ @access_token }} class="">
        <Profile
          id="profile"
          profile={{ @profile }}
          access_token={{ @access_token }}
          class="my-4 md:max-w-3xl mx-auto" />
      </div>
    </div>
    """
  end

  defp fetch_user(access_token) do
    Supabase.auth() |> GoTrue.get_user(access_token) |> IO.inspect()
  end

  defp fetch_user(access_token, socket) do
    case fetch_user(access_token) do
      {:ok, user} -> {:ok, assign(socket, user: user), user}
      _ -> {:error, redirect(socket, to: "/logout")}
    end
  end

  defp fetch_profile(access_token, user, socket) do
    profile_response =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("profiles")
      |> Postgrestex.eq("id", user["id"])
      |> Postgrestex.call()
      |> Supabase.json()

    user_avatar = Map.get(user, "user_metadata", %{}) |> Map.get("avatar_url")

    case profile_response do
      %{body: [profile]} ->
        {:ok, Map.put(profile, "email", user["email"]) |> Map.put("user_avatar", user_avatar)}

      %{body: []} ->
        create_profile(access_token, user, socket)
    end
  end

  defp create_profile(access_token, user, socket) do
    username = Map.get(user, "user_metadata", %{}) |> Map.get("full_name")

    %{body: profile, status: 201} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("profiles")
      |> Postgrestex.insert(%{username: username, id: user["id"]}, true)
      |> Postgrestex.eq("id", user["id"])
      |> Postgrestex.call()
      |> Supabase.json()

    {:ok, Map.put(profile, "email", user["email"])}
  end

  defp check_token_expiration(access_token, refresh_token, socket) do
    {:ok, %{"exp" => exp}} = Joken.peek_claims(access_token) |> IO.inspect()

    cond do
      exp - System.system_time(:second) < 10 ->
        with {:ok, access_token, refresh_token} <-
               refresh_access_token(refresh_token) |> IO.inspect() do
          {:ok, assign(socket, access_token: access_token, refresh_token: refresh_token),
           access_token}
        else
          :error -> {:error, redirect(socket, to: "/logout")}
        end

      true ->
        {:ok, assign(socket, access_token: access_token, refresh_token: refresh_token),
         access_token}
    end
  end

  defp refresh_access_token(refresh_token) do
    case Supabase.auth()
         # TODO refresh in session
         |> GoTrue.refresh_access_token(refresh_token) do
      {:ok, %{"access_token" => at, "refresh_token" => rt}} -> {:ok, at, rt}
      _ -> :error
    end
  end
end
