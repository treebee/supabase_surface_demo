defmodule SupabaseSurfaceDemoWeb.PageLive do
  use Surface.LiveView

  alias Surface.Components.Form
  alias Surface.Components.Form.Submit
  alias SupabaseSurfaceDemoWeb.Components.Auth

  data(access_token, :string, default: nil)
  data(refresh_token, :string, default: nil)

  @impl true
  def mount(_params, %{"access_token" => at, "refresh_token" => rt}, socket) do
    {:ok, assign(socket, access_token: at, refresh_token: rt)}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <Auth
        :if={{ is_nil(@access_token) }}
        id="supabase-auth"
        redirect_url="/"
        class="md:max-w-2xl mx-auto"
        magic_link={{ true }}
        providers={{ ["github", "google"] }}
        />
      <div :if={{ @access_token }}>
      <h1>Hello Surface</h1>
      logged in
      <Form method="post" action="/logout">
        <Submit class="bg-brand-800 w-full py-2 rounded-md font-semibold text-white">Logout</Submit>
      </Form>
      </div>
    </div>
    """
  end
end
