defmodule SupabaseSurfaceDemoWeb.PageLive do
  use SupabaseSurfaceDemoWeb, :surface_view

  alias SupabaseSurface.Components.SupabaseImage
  alias SupabaseSurfaceDemo.Accounts
  alias SupabaseSurfaceDemoWeb.Components.Profile
  alias SupabaseSurface.Components.Divider
  alias SupabaseSurface.Components.Dropdown
  alias SupabaseSurface.Components.DropdownItem
  alias SupabaseSurface.Components.DropdownItemIcon
  alias SupabaseSurface.Components.Typography
  alias SupabaseSurface.Components.Icons.SocialIcon

  data access_token, :string, default: nil

  @impl true
  def mount(_params, %{"access_token" => access_token}, socket) do
    socket = assign_new(socket, :user, fn -> Accounts.get_user!(access_token) end)
    {:ok, assign(socket, access_token: access_token)}
  end

  @impl true
  def mount(_, _, socket), do: {:ok, socket}

  @impl true
  def handle_params(_, _, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col flex-1 h-screen">
    <header class="bg-dark-700">
      <nav class="flex justify-end container mx-auto max-w-3xl items-center py-4">
          <Dropdown id="user-menu"
            transition={{
              enter: "transition ease-out origin-top-right duration-300",
              enter_start: "opacity-0 transform scale-90",
              enter_end: "opacity-100 transform scale-100",
              leave: "transition origin-top-right ease-in duration-100",
              leave_start: "opacity-100 transform scale-100",
              leave_end: "opacity-0 transform scale-90"
            }}
            side="bottom"
            align="end"
          >
            <DropdownItem to="/">
              <DropdownItemIcon>{{ Heroicons.Outline.user(class: "w-4 h-4") }}</DropdownItemIcon>
              <Typography.Text>Profile</Typography.Text>
            </DropdownItem>
            <DropdownItem to="/">
              <DropdownItemIcon>{{ Heroicons.Outline.cog(class: "w-4 h-4") }}</DropdownItemIcon>
              <Typography.Text>Settings</Typography.Text>
            </DropdownItem>
            <template slot="items">
              <Divider light={{ true }} />
            </template>
            <DropdownItem to="/logout" method={{ :post }}>
              <DropdownItemIcon>{{ Heroicons.Outline.logout(class: "w-4 h-4") }}</DropdownItemIcon>
              <Typography.Text>Logout</Typography.Text>
            </DropdownItem>
            <button
              class="rounded-full"
              @click="open = !open" @click.away="open = false" @keydown.escape.window="open = false"
            >
              <SupabaseImage id="avatar" src={{ @user["user_metadata"]["avatar_url"] }} width="30" height="30" class="rounded-full" />
            </button>
          </Dropdown>
      </nav>
    </header>
    <main role="main" class="container mx-auto py-10 max-w-3xl flex-grow">
      <p class="alert alert-info" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="info">{{ live_flash(@flash, :info) }}</p>

      <p class="alert alert-danger" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="error">{{ live_flash(@flash, :error) }}</p>

        <Profile id="profile" user={{ @user }} access_token={{ @access_token }} />
    </main>
    <footer class="bg-dark-700">
      <div class="grid grid-cols-3 gap-8 py-2 max-w-3xl container mx-auto">
          <Typography.Link href="https://supabase.io" class="flex items-center">Supabase.io</Typography.Link>
          <Typography.Link class="flex items-center justify-center" href="https://github.com/treebee/supabase_surface_demo">
            <SocialIcon provider="github" class="w-4 h-4 mr-2" />
            Repository
          </Typography.Link>
         <Typography.Link class="flex items-center justify-end" href="https://github.com/treebee/supabase-surface">
            <SocialIcon provider="github" class="w-4 h-4 mr-2" />
            Component Repo
         </Typography.Link>
      </div>
    </footer>
    </div>
    """
  end
end
