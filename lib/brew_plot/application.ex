defmodule BrewPlot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BrewPlotWeb.Telemetry,
      BrewPlot.Repo,
      {DNSCluster, query: Application.get_env(:brew_plot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BrewPlot.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BrewPlot.Finch},
      # Start a worker by calling: BrewPlot.Worker.start_link(arg)
      # {BrewPlot.Worker, arg},
      # Start to serve requests, typically the last entry
      BrewPlotWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BrewPlot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BrewPlotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
