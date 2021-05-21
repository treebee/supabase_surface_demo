defmodule SupabaseSurfaceDemoWeb.Components.Profile do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, TextInput, Label}
  alias SupabaseSurface.Components.Button
  alias SupabaseSurfaceDemo.Accounts

  @doc "The profile data to display"
  prop(user, :map, required: true)

  @doc "CSS classes to pass to the outer HTML element"
  prop(class, :css_class, default: "")

  @doc "Access Token of the currently logged in user."
  prop(access_token, :string, required: true)

  data avatar_url, :string, default: ""

  @impl true
  def update(assigns, socket) do
    socket =
      case Accounts.get_profile(assigns.access_token, assigns.user["id"]) do
        {:ok, profile} ->
          assign(socket, profile: profile)

        {:error, :no_result} ->
          assign(socket, profile: Accounts.create_profile(assigns.access_token, assigns.user))

        _error ->
          put_flash(socket, :danger, "Couldn't fetch profile")
      end

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={{ @class }}>
      <h1 class="text-brand-800 text-lg font-semibold">Hi {{ username(@user) }}</h1>
      <div class={{ "grid grid-cols-1 md:grid-cols-2 gap-16 text-white my-4 px-8 py-6 bg-gray-700 border border-gray-600 border-opacity-60 rounded-md", @class }}>
        <div class="order-last md:order-first">
        <Form for={{ :profile }} change="change" submit="submit"
          >
          <Field name="email" class="font-semibold text-md mb-4">
            <Label>Email address</Label>
            <div class="flex items-center mt-2">
              <TextInput
                value="{{ @user["email"] }}"
                opts={{ readonly: true }}
                class="text-xs px-4 py-2 text-gray-400 bg-transparent border border-gray-400 rounded-md w-full" />
            </div>
          </Field>
          <Field name="username" class="font-semibold text-md mb-4">
            <Label>Username</Label>
            <div class="flex items-center mt-2">
              <TextInput
                value="{{ username(@user) }}" class="placeholder-gray-400 text-xs px-4 py-2 bg-transparent border border-gray-400 rounded-md w-full" />
            </div>
          </Field>
          <Field name="website" class="font-semibold text-md mb-4">
            <Label>Website</Label>
            <div class="flex items-center mt-2">
              <TextInput
                value="{{ nil }}" opts={{ placeholder: "Your website" }} class="placeholder-gray-400 text-xs px-4 py-2 bg-transparent border border-gray-400 rounded-md w-full" />
            </div>
          </Field>

          <Button
            html_type="submit" block={{ true }} size="small"
            class="rounded-md font-semibold uppercase mt-6">update</Button>
        </Form>
        <div class="mt-8">
          <Button block={{ true }} type="outline" size="small" to="/logout"
            class="rounded-md text-white">Logout</Button>
        </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("change", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"profile" => profile}, socket) do
    resp =
      Supabase.init(access_token: socket.assigns.access_token)
      |> Postgrestex.from("profiles")
      |> Postgrestex.eq("id", socket.assigns.profile["id"])
      |> Postgrestex.update(Map.delete(profile, "email"))
      |> Postgrestex.call()
      |> Supabase.json()

    case resp do
      # TODO handle error
      :error ->
        {:noreply, socket}

      %{body: [profile]} ->
        {:noreply, assign(socket, profile: Map.merge(socket.assigns.profile, profile))}
    end
  end

  defp username(user) do
    user["user_metadata"]["full_name"]
  end
end
