defmodule SupabaseSurface.Components.SupabaseImage do
  use Surface.LiveComponent

  prop src, :string, required: true

  prop width, :string

  prop height, :string

  prop class, :css_class

  @impl true
  def update(assigns, socket) do
    src = get_full_image_url(assigns.src)
    socket = assign(socket, assigns) |> assign(src: src)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <img src={{ Map.get(assigns, :src) }} width={{ @width }} height={{ @height }} class={{ @class }} />
    """
  end

  defp get_full_image_url("http" <> _rest = src), do: src

  defp get_full_image_url(blob) do
    {:ok, %{"signedUrl" => path}} =
      Supabase.Connection.new()
      |> Supabase.Storage.Objects.sign("avatars", blob)

    URI.merge(Application.get_env(:supabase, :base_url), "/storage/v1" <> path) |> URI.to_string()
  end
end
