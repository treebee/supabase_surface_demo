defmodule SupabaseSurfaceDemoWeb.LoginLive do
  use Surface.LiveView

  alias SupabaseSurface.Components.Auth

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto py-32">
      <Auth
        id="supabase-auth"
        redirect_url="/"
        class="md:max-w-lg mx-auto"
        magic_link={{ true }}
        providers={{ ["github", "google"] }}
        />
    </div>
    """
  end
end
