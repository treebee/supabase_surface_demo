defmodule SupabaseSurfaceDemoWeb.PageLive do
  use Surface.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    Hello Surface
    """
  end
end
