defmodule SupabaseSurfaceDemoWeb.Components.Profile.Example do
  use Surface.Catalogue.Example,
    subject: SupabaseSurfaceDemoWeb.Components.Profile,
    height: "500px"

    alias SupabaseSurfaceDemoWeb.Components.Profile

    data profile, :map, default: %{"id" => "1", "email" => "example@gmail.co", "website" => "https://example.blog.com", "username" => "Ahsoka Tano"}

    def render(assigns) do
      ~H"""
      <Profile id="supabase-profile" profile={{ @profile }} access_token="top-secret"/>
      """
    end
end
