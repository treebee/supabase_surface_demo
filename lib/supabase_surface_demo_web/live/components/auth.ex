defmodule SupabaseSurfaceDemoWeb.Components.Auth do
  use Surface.LiveComponent

  alias Surface.Components.Link.Button
  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, Label, TextInput, Submit}
  alias SupabaseSurfaceDemoWeb.Components.Typography.Text
  alias SupabaseSurfaceDemoWeb.Components.Icons.SocialIcon

  @doc "URL to redirect to after successful login"
  prop(redirect_url, :string, default: "/")

  @doc "API endpoint for updating the session with access_token and refresh_token"
  prop(session_url, :string, default: "/session")

  @doc "Classes to apply to the component"
  prop(class, :css_class)

  @doc "If sign in via magic link should be enabled"
  prop(magic_link, :boolean, default: true)

  @doc "Providers to use for social auth"
  prop(providers, :list)

  data(user, :map, default: %{"email" => ""})
  data(msg, :string, default: nil)
  data(type, :atom, values: [:default, :success, :danger], default: :default)

  @impl true
  def render(assigns) do
    ~H"""
    <div
      :hook="SupabaseAuth"
      data-redirect-url="{{ @redirect_url }}"
      data-session-url="{{ @session_url }}"
      data-magic-link="{{ @magic_link }}"
      class="text-white px-8 py-12 bg-gray-700 border border-gray-600 border-opacity-60 rounded-md {{ @class }}"
      >
      <div :if={{ @providers }}>
        <Text class="font-semibold">Sign in with</Text>
        <div class="pt-2 pb-8">
          <span :for={{ provider <- @providers }}>
            <button
              :on-click="authorize"
              phx-value-provider={{ provider }}
              class="my-2 py-2 w-full bg-gray-600 font-semibold text-sm flex items-center justify-center rounded-md">
              <SocialIcon class="mr-2 w-4 h-4" provider={{ provider }} />Sign up with {{ provider }}
            </button>
          </span>
        </div>
      </div>
      <Form :if={{ @magic_link }} for={{ :user }} change="change" submit="submit">
        <Field name="email" class="font-semibold text-md mb-4">
          <Label>Email address</Label>
          <div class="control flex items-center mt-4">
            <TextInput
              value="{{ @user["email"] }}" opts={{ placeholder: "Your email address" }} class="placeholder-gray-400 text-xs pl-10 py-2 bg-transparent border border-gray-400 rounded-md w-full" />
            <div class="absolute">{{ Heroicons.Outline.mail(class: "w-6 h-6 ml-2 text-gray-400") }}</div>
          </div>
        </Field>
        <Submit class="bg-brand-800 w-full py-2 rounded-md font-semibold text-white">Send Magic Link</Submit>
      </Form>
      <Text :if={{ @msg }} type={{ @type }} class="py-2 px-1">{{ @msg }}</Text>
    </div>
    """
  end

  @impl true
  def handle_event("change", %{"user" => %{"email" => email}}, socket) do
    {:noreply, update(socket, :user, fn user -> Map.put(user, "email", email) end)}
  end

  @impl true
  def handle_event("submit", %{"user" => %{"email" => email}}, socket) do
    socket =
      case Supabase.Connection.new()
           |> Supabase.Auth.GoTrue.send_magic_link_email(email)
           |> IO.inspect() do
        {:ok, _} -> assign(socket, msg: "Check your emails for magic link")
        {:error, %{"code" => 422, "msg" => msg}} -> assign(socket, msg: msg, type: :danger)
        _ -> assign(socket, msg: "Something went wrong. Please try again.", type: :danger)
      end

    {:noreply, assign(socket, :user, %{"email" => ""})}
  end

  @impl true
  def handle_event("authorize", %{"provider" => provider}, socket) do
    url = provider_url(provider)
    {:noreply, redirect(socket, external: url)}
  end

  defp provider_url(provider),
    do: Supabase.Connection.new().base_url <> "/auth/v1/authorize?provider=#{provider}"
end
