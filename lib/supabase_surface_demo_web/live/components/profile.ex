defmodule SupabaseSurfaceDemoWeb.Components.Profile do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias SupabaseSurface.Components.Button
  alias SupabaseSurface.Components.{EmailInput, TextInput, Typography}
  alias SupabaseSurfaceDemo.Accounts
  alias SupabaseSurfaceDemo.Profile

  @doc "The profile data to display"
  prop(user, :map, required: true)

  @doc "CSS classes to pass to the outer HTML element"
  prop(class, :css_class, default: "")

  @doc "Access Token of the currently logged in user."
  prop(access_token, :string, required: true)

  data avatar_url, :string, default: ""
  data changeset, :any

  @impl true
  def update(assigns, socket) do
    socket =
      case Accounts.get_profile(assigns.access_token, assigns.user["id"]) do
        {:ok, profile_response} ->
          profile = Map.merge(%Profile{}, profile_response)
          assign(socket, profile: profile, changeset: Profile.changeset(profile, %{}))

        {:error, :no_result} ->
          {:ok, profile_response} = Accounts.create_profile(assigns.access_token, assigns.user)
          profile = Map.merge(%Profile{}, profile_response)
          assign(socket, profile: profile, changeset: Profile.changeset(profile, %{}))

        _error ->
          put_flash(socket, :danger, "Couldn't fetch profile")
      end

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={{ @class }}>
      <Typography.Title level={{ 2 }}>Profile</Typography.Title>
      <div class={{ "grid grid-cols-1 md:grid-cols-2 gap-16 text-white my-4 px-8 py-6 bg-gray-700 border border-gray-600 border-opacity-60 rounded-md", @class }}>
        <div class="order-last md:order-first">
        <Form for={{ @changeset }} as={{ :profile }} change="change" submit="submit"
          >
          <div class="grid grid-cols-1 gap-4">
          <EmailInput name={{ :email }} label={{ "Email address" }} opts={{ readonly: true }} />
          <TextInput name={{ :username }} label={{ "Username" }} />
          <TextInput name={{ :website }} label={{ "Website" }} />
          </div>
          <Button
            html_type="submit" block={{ true }} size="small"
            disabled={{ not form_valid?(@changeset) }}
            class="rounded-md font-semibold uppercase mt-6"
          >
          update
          </Button>
        </Form>
        <div class="mt-8">
          <Button block={{ true }} type="outline" size="small" to="/logout"
            class="rounded-md text-white"
          >
          Logout
          </Button>
        </div>
        </div>
      </div>
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
    case Accounts.update_profile(
           socket.assigns.access_token,
           socket.assigns.user["id"],
           socket.assigns.profile,
           params
         ) do
      {:error, _} ->
        {:noreply, socket}

      {:ok, profile} ->
        profile = Map.merge(%Profile{}, profile)
        {:noreply, assign(socket, profile: profile, changeset: Profile.changeset(profile, %{}))}
    end
  end

  defp form_valid?(changeset) do
    changeset.valid? and changeset.changes != %{}
  end
end
