defmodule SupabaseSurfaceDemoWeb.Components.Typography.Text do
  use Surface.Component

  @doc "The type (color) of the text"
  prop type, :atom, values: [:default, :success, :danger], default: :default

  @doc "CSS classes to apply"
  prop class, :css_class

  @doc "The content"
  slot default, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <span class={{ text_color(@type) }}><p class={{ @class }}><slot /></p></span>
    """
  end

  defp text_color(:default), do: "text-gray-200"
  defp text_color(:success), do: "text-green-500"
  defp text_color(:danger), do: "text-red-500"
end
