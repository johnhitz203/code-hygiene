defmodule CodeHygiene.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  use Boundary, top_level?: true, deps: [CodeHygiene, CodeHygieneWeb]

  @impl true
  def start(_type, _args) do
    children = [
      CodeHygieneWeb.Telemetry,
      CodeHygiene.Repo,
      {DNSCluster, query: Application.get_env(:code_hygiene, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CodeHygiene.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CodeHygiene.Finch},
      # Start a worker by calling: CodeHygiene.Worker.start_link(arg)
      # {CodeHygiene.Worker, arg},
      # Start to serve requests, typically the last entry
      CodeHygieneWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CodeHygiene.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CodeHygieneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
