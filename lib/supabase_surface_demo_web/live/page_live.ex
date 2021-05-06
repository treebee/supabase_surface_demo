defmodule SupabaseSurfaceDemoWeb.PageLive do
  use Surface.LiveView

  alias Surface.Components.Form
  alias Surface.Components.Form.Submit
  alias SupabaseSurfaceDemoWeb.Components.Auth
  alias SupabaseSurfaceDemoWeb.Components.Profile

  data(access_token, :string, default: nil)
  data(refresh_token, :string, default: nil)

  @impl true
  def mount(_params, %{"access_token" => at, "refresh_token" => rt}, socket) do
    {socket, at, rt} =
      case fetch_user(at) do
        :error ->
          case Supabase.Connection.new() |> Supabase.Auth.GoTrue.refresh_access_token(rt) do
            {:ok, %{"access_token" => at, "refresh_token" => rt}} ->
              case fetch_user(at) do
                :error -> {socket, nil, nil}
                user -> {assign(socket, user: user), at, rt}
              end

            _ ->
              {socket, nil, nil}
          end

        user ->
          {assign(socket, user: user), at, rt}
      end

    socket =
      case Map.get(socket.assigns, :user) do
        nil ->
          socket

        user ->
          profile = fetch_profile(at, user["id"]) |> IO.inspect()
          assign(socket, :profile, Map.put(profile, "email", user["email"]))
      end

    {:ok, assign(socket, access_token: at, refresh_token: rt)}
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
        class="md:max-w-xl mx-auto"
        magic_link={{ true }}
        providers={{ ["github", "google"] }}
        />
      <div :if={{ @access_token }} class="">
      <Profile id="profile" profile={{ @profile }} class="my-4 md:max-w-2xl mx-auto" />
     </div>
    </div>
    """
  end

  defp fetch_user(access_token) do
    case Supabase.Connection.new()
         |> Supabase.Auth.GoTrue.user(access_token) do
      {:ok, user} -> user
      {:error, %{"code" => 401}} -> :error
    end
  end

  defp fetch_profile(access_token, user_id) do
    %{body: [profile]} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("profiles")
      |> Postgrestex.eq("id", user_id)
      |> Postgrestex.call()
      |> Supabase.json()

    profile
  end
end
