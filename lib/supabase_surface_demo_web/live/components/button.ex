defmodule SupabaseSurfaceDemoWeb.Components.Button do
  use Surface.Component

  @doc "Triggers on click"
  prop click, :event

  @doc "The content of the button"
  slot default, required: true

  def render(assigns) do
    ~H"""
    <button phx-click="{{ @click }}"><slot name="default"></slot></button>
    """
  end
end
