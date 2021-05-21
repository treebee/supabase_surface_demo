defmodule SupabaseSurfaceDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SupabaseSurfaceDemo.Repo,
      # Start the Telemetry supervisor
      SupabaseSurfaceDemoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SupabaseSurfaceDemo.PubSub},
      # Start the Endpoint (http/https)
      SupabaseSurfaceDemoWeb.Endpoint
      # Start a worker by calling: SupabaseSurfaceDemo.Worker.start_link(arg)
      # {SupabaseSurfaceDemo.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SupabaseSurfaceDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SupabaseSurfaceDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
