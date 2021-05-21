defmodule SupabaseSurfaceDemoWeb.PageLive do
  use SupabaseSurfaceDemoWeb, :surface_view

  alias SupabaseSurfaceDemo.Accounts
  alias SupabaseSurface.Components.Button
  alias SupabaseSurfaceDemoWeb.Components.Profile

  data access_token, :string, default: nil

  @impl true
  def mount(_params, %{"access_token" => access_token}, socket) do
    socket = assign_new(socket, :user, fn -> Accounts.get_user!(access_token) end)
    {:ok, assign(socket, access_token: access_token)}
  end

  @impl true
  def mount(_, _, socket), do: {:ok, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <header class="bg-dark-700">
      <nav class="flex justify-end container mx-auto max-w-3xl">
        <div class="py-4">
          <Button id="logout" to="/logout" size="medium" type="link">Logout</Button>
        </div>
      </nav>
    </header>
    <main role="main" class="container mx-auto py-10 max-w-3xl">
      <p class="alert alert-info" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="info">{{ live_flash(@flash, :info) }}</p>

      <p class="alert alert-danger" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="error">{{ live_flash(@flash, :error) }}</p>

        <Profile id="profile" user={{ @user }} access_token={{ @access_token }} />
    </main>
    """
  end

  defp username(user) do
    user["user_metadata"]["full_name"]
  end
end
