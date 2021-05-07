defmodule SupabaseSurfaceDemoWeb.Components.Auth.MagicLink do
  use Surface.Catalogue.Example,
    subject: SupabaseSurfaceDemoWeb.Components.Auth,
    height: "500px"

    alias SupabaseSurfaceDemoWeb.Components.Auth

    def render(assigns) do
      ~H"""
      <Auth id="supabase-auth" />
      """
    end
end
