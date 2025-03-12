defmodule PhantomChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhantomChatWeb.Telemetry,
      PhantomChat.Repo,
      {DNSCluster, query: Application.get_env(:phantom_chat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhantomChat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhantomChat.Finch},
      # Start a worker by calling: PhantomChat.Worker.start_link(arg)
      # {PhantomChat.Worker, arg},
      # Start to serve requests, typically the last entry
      PhantomChatWeb.Endpoint,
      {Helper.HandleRefreshNewLogin, name: Helper.HandleRefreshNewLogin},
      {Oban, Application.fetch_env!(:phantom_chat, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhantomChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhantomChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
