defmodule SupabaseSurfaceDemoWeb.Router do
  use SupabaseSurfaceDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SupabaseSurfaceDemoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SupabaseSurface.Plugs.Session
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: SupabaseSurfaceDemoWeb.Telemetry)
    end
  end

  scope "/", SupabaseSurfaceDemoWeb do
    pipe_through(:browser)

    get "/public/:user_id/:filename", ImageController, :public

    live "/", PageLive, :index
    live "/login", LoginLive, :index
    live "/:page", PageLive, :index

    post "/logout", SessionController, :logout
  end

  # Other scopes may use custom stacks.
  scope "/", SupabaseSurfaceDemoWeb do
    pipe_through(:api)

    post "/session", SessionController, :set_session
  end
end
