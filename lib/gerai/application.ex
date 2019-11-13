defmodule Gerai.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Gerai.Worker.start_link(arg)
      # {Gerai.Worker, arg},
      {Gerai.Cache, name: GeraiJson},
      {Plug.Cowboy, scheme: :http, plug: Gerai.Router, options: [port: 8080]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gerai.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
