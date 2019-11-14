defmodule Gerai.MixProject do
  use Mix.Project

  def project do
    [
      app: :gerai,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Docs
      name: "gerai",
      description: "Gerai is an OTP-compliant JSON object cache for Elixir.",
      package: package(),
      source_url: "https://github.com/boonious/gerai",
      homepage_url: "https://github.com/boonious/gerai",
      docs: [
        main: "gerai",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gerai.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12", only: :test},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"}
    ]
  end

  defp package do
    [
      name: "gerai",
      maintainers: ["Boon Low"],
      licenses: ["Apache 2.0"],
      links: %{
        Changelog: "https://github.com/boonious/gerai/blob/master/CHANGELOG.md",
        GitHub: "https://github.com/boonious/gerai"
      }
    ]
  end
end
