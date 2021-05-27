defmodule SupabaseSurfaceDemoWeb.Components.Profile do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.LiveFileInput
  alias SupabaseSurface.Components.Button
  alias SupabaseSurface.Components.{EmailInput, TextInput, Typography}
  alias SupabaseSurfaceDemo.Accounts
  alias SupabaseSurfaceDemo.Profile

  @doc "The profile data to display"
  prop(profile, :struct, required: true)

  @doc "CSS classes to pass to the outer HTML element"
  prop(class, :css_class, default: "")

  @doc "Access Token of the currently logged in user."
  prop(access_token, :string, required: true)

  prop uploads, :struct, required: true
  data changeset, :any

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns) |> assign(changeset: Profile.changeset(assigns.profile, %{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={{ @class }}>
      <Typography.Title level={{ 2 }}>Profile</Typography.Title>
      <Form for={{ @changeset }} as={{ :profile }} change="change" submit="submit"
        class={{ "grid grid-cols-1 md:grid-cols-2 gap-16 text-white my-4 px-8 py-6 bg-gray-700 border border-gray-600 border-opacity-60 rounded-md", @class }}
      >
        <div class="order-last md:order-first">
          <div class="grid grid-cols-1 gap-4">
            <EmailInput name={{ :email }} label={{ "Email address" }} opts={{ readonly: true }} />
            <TextInput name={{ :username }} label={{ "Username" }} />
            <TextInput name={{ :website }} label={{ "Website" }} />
          </div>
          <Button
            html_type="submit" block={{ true }} size="small"
            disabled={{ not form_valid?(@changeset, @uploads) }}
            class="rounded-md font-semibold uppercase mt-6"
          >
          update
          </Button>
          <div class="mt-8">
            <Button block={{ true }} type="outline" size="small" to="/logout"
              class="rounded-md text-white"
            >
            Logout
            </Button>
          </div>
        </div>
        <div class="pt-8 flex flex-col items-center">
          <div :if={{ length(@uploads.avatar.entries) == 1}}>
           {{ live_img_preview @uploads.avatar.entries |> hd(), width: 220, height: 220, class: "rounded-full" }}
          </div>
          <img :if={{ length(@uploads.avatar.entries) != 1}} src="{{ @profile.avatar_url }}" access_token={{ @access_token }} width="220" height="220" class="rounded-full" />
          <div class="flex justify-center relative">
            <Button type="outline" disabled={{ true }} class="uppercase mt-4 flex items-center gap-2">
            {{ Heroicons.Outline.photograph(class: "w-4 h-4") }}
            upload
            </Button>
            <LiveFileInput upload={{ @uploads.avatar }} class="opacity-0 cursor-pointer absolute left-0 top-0 right-0 bottom-0" />
          </div>
        </div>
      </Form>
    </div>
    """
  end

  @impl true
  def handle_event("change", params, socket) do
    changeset =
      Profile.changeset(socket.assigns.profile, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("submit", params, socket) do
    params = handle_upload(params, socket)

    case Accounts.update_profile(
           socket.assigns.access_token,
           socket.assigns.profile.user_id,
           socket.assigns.profile,
           params
         ) do
      {:error, _} ->
        {:noreply, socket}

      {:ok, profile} ->
        socket =
          socket
          |> assign(profile: profile, changeset: Profile.changeset(profile, %{}))

        {:noreply, socket}
    end
  end

  defp handle_upload(params, %{assigns: %{uploads: %{avatar: []}}}), do: params

  defp handle_upload(params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        key = "public/" <> socket.assigns.profile.user_id <> "/avatar." <> extension(entry)

        with {:ok, %{"statusCode" => "23505"}} <-
               upload_file(socket.assigns.access_token, key, path, entry),
             {:ok, %{"Key" => "avatars/" <> blob_key}} <-
               update_file(socket.assigns.access_token, key, path, entry) do
          blob_key
        else
          {:ok, %{"Key" => "avatars/" <> blob_key}} -> blob_key
        end
      end)

    case uploaded_files do
      [uploaded_file] -> Map.put(params, "avatar_url", uploaded_file)
      [] -> params
    end
  end

  def upload_file(access_token, key, path, entry) do
    Supabase.storage(access_token)
    |> Supabase.Storage.from("avatars")
    |> Supabase.Storage.upload(
      key,
      path,
      content_type: entry.client_type
    )
  end

  def update_file(access_token, key, path, entry) do
    Supabase.storage(access_token)
    |> Supabase.Storage.from("avatars")
    |> Supabase.Storage.update(key, path, content_type: entry.client_type)
  end

  defp form_valid?(changeset, uploads) do
    changeset.valid? and (changeset.changes != %{} or length(uploads.avatar.entries) > 0)
  end

  defp extension(entry), do: MIME.extensions(entry.client_type) |> hd()
end
