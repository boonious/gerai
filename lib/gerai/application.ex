defmodule Gerai.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts the cache server, with a fixed name
      # The server name could be configurable via environmental variable
      {Gerai.Cache, name: GeraiJson},

      # Starts the HTTP interface which could also be made optional via configuration
      {Plug.Cowboy, scheme: :http, plug: Gerai.Router, options: [port: 8080]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gerai.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
