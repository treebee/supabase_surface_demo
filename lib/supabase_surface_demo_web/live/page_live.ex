defmodule SupabaseSurfaceDemoWeb.PageLive do
  use Surface.LiveView

  alias SupabaseSurfaceDemoWeb.Components.Auth

  data access_token, :string, default: nil
  data refresh_token, :string, default: nil

  @impl true
  def mount(_params, %{"access_token" => at, "refresh_token" => rt}, socket) do
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
      <h1>Hello Surface</h1>
      <Auth :if={{ is_nil(@access_token) }} id="supabase-auth" redirect_url="/" />
      <div :if={{ @access_token }}>
      logged in
      </div>
    </div>
    """
  end
end
