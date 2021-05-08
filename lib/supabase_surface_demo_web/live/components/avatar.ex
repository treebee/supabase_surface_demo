defmodule SupabaseSurfaceDemoWeb.Components.Avatar do
  use Surface.LiveComponent

  prop access_token, :string, required: true

  prop profile, :map, required: true

  prop class, :css_class

  @impl true
  def render(assigns) do
    ~H"""
    <div id="profile-avatar" :hook="SupabaseAvatar"
      data-access-token={{ @access_token }}
      data-image-url={{ get_avatar_url(@profile) }}
      class={{ "grid grid-cols-1 gap-1 mx-auto", @class }}
    >
      <img
        class={{ "rounded rounded-full border-gray-700", "h-64 w-64": not user_avatar?(@profile), "h-32 w-32": user_avatar?(@profile) }}
        src={{ Map.get(@profile, "user_avatar") }} />
      <div
        :if={{ not user_avatar?(@profile) }}
        class="flex justify-center">
        <label for="single"
          class="p-2 bg-brand-800 rounded-md text-white uppercase font-semibold"
        >Upload</label>
        <input
          id="single"
          :hook="SupabaseUpload"
          type="file"
          accept="image/*"
          onchange="uploadHook.uploadAvatar(event)"
          data-access-token={{ @access_token }}
          data-upload-url={{ upload_url() }}
          data-phx-component={{ @myself }}
          style={{ visibility: 'hidden', position: 'absolute' }}
        />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("avatar-upload", %{"Key" => "avatars/" <> filename}, socket) do
    Supabase.init(access_token: socket.assigns.access_token)
    |> Postgrestex.from("profiles")
    |> Postgrestex.update(%{"avatar_url" => filename})
    |> Postgrestex.call()

    {:noreply,
     socket
     |> assign(profile: Map.put(socket.assigns.profile, "avatar_url", filename))
     |> push_event("change-avatar", %{})}
  end

  defp upload_url() do
    conn = Supabase.Connection.new()
    URI.merge(conn.base_url, "/storage/v1/object/avatars/") |> URI.to_string()
  end

  defp get_avatar_url(%{"avatar_url" => avatar_url}) do
    conn = Supabase.Connection.new()
    URI.merge(conn.base_url, "/storage/v1/object/avatars/#{avatar_url}") |> URI.to_string()
  end

  defp get_avatar_url(_), do: ""

  def user_avatar?(profile) do
    not is_nil(Map.get(profile, "user_avatar"))
  end
end
