defmodule SupabaseSurfaceDemoWeb.Components.Icons.SocialIcon do
  use Surface.Component

  alias SupabaseSurfaceDemoWeb.Components.Icons.GitHub
  alias SupabaseSurfaceDemoWeb.Components.Icons.Google

  @doc "CSS class to pass to the svg"
  prop(class, :css_class)

  @doc "provider"
  prop(provider, :string)

  # TODO find nicer solution for selective rendering of icons
  def render(assigns) do
    ~H"""
    <GitHub :if={{ @provider == "github" }} class={{ @class }} />
    <Google :if={{ @provider == "google" }} class={{ @class }} />
    """
  end
end
