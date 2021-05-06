defmodule SupabaseSurfaceDemoWeb.Components.Auth do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.Label
  alias Surface.Components.Form.TextInput
  alias Surface.Components.Form.Submit

  @doc "URL to redirect to after successful login"
  prop redirect_url, :string, default: "/"

  @doc "API endpoint for updating the session with access_token and refresh_token"
  prop session_url, :string, default: "/session"

  data user, :map, default: %{"email" => ""}

  @impl true
  def render(assigns) do
    ~H"""
    <div id="supabase-auth" :hook="SupabaseAuth" data-redirect-url="{{ @redirect_url }}" data-session-url="{{ @session_url }}">
      <p>Sign in via magic link with your email below</p>
      <Form for={{ :user }} change="change" submit="submit">
        <Field name="email">
          <Label />
          <div class="control">
            <TextInput value="{{ @user["email"] }}" opts={{ placeholder: "Your email" }} />
          </div>
        </Field>
        <Submit>Send Magic Link</Submit>
      </Form>
    </div>
    """
  end

  @impl true
  def handle_event("change", %{"user" => %{"email" => email}}, socket) do
    {:noreply, update(socket, :user, fn user -> Map.put(user, "email", email) end)}
  end

  @impl true
  def handle_event("submit", %{"user" => %{"email" => email}}, socket) do
    :ok = Supabase.auth().send_magic_link(email)
    {:noreply, assign(socket, :user, %{"email" => ""})}
  end
end
