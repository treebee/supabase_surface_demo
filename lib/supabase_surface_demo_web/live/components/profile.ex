defmodule SupabaseSurfaceDemoWeb.Components.Profile do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, TextInput, Submit, Label}

  @doc "The profile data to display"
  prop(user, :map, required: true)

  @doc "CSS classes to pass to the outer HTML element"
  prop(class, :css_class, required: false)

  @doc "Access Token of the currently logged in user."
  prop(access_token, :string, required: true)

  data avatar_url, :string, default: ""

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

          <Submit class="bg-brand-800 hover:bg-brand-900 w-full py-2 rounded-md font-semibold text-white uppercase">update</Submit>
        </Form>
        <Form for={{ :logout }} method="post" action="/logout">
          <Submit class="border-2 border-brand-800 hover:bg-gray-900 w-full mt-8 py-2 rounded-md font-semibold text-white">Logout</Submit>
        </Form>
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
