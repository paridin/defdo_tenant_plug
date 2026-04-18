defmodule DefdoTenantPlug.MixProject do
  @moduledoc false
  use Mix.Project

  @organization "defdo"
  @source_url "https://github.com/defdo-dev/defdo_tenant_plug"

  def project do
    [
      app: :defdo_tenant_plug,
      version: "0.1.0",
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
      name: "Defdo Tenant Plug",
      source_url: @source_url,
      homepage_url: "https://foss.defdo.ninja"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:defdo_tenant, "~> 0.8", organization: @organization},
      {:plug, "~> 1.14"},
      {:gettext, "~> 1.0", optional: true},
      {:igniter, "~> 0.6", optional: true},
      {:phoenix, "~> 1.8.1", optional: true},
      {:phoenix_ecto, "~> 4.5", optional: true},
      {:phoenix_html, "~> 4.3", optional: true},
      {:phoenix_live_view, "~> 1.1", optional: true},
      {:phoenix_live_dashboard, "~> 0.8.3", optional: true},
      {:bandit, "~> 1.5", optional: true},
      {:dns_cluster, "~> 0.2.0", optional: true},
      {:lazy_html, ">= 0.1.0", only: :test, optional: true},
      {:absinthe_plug, "~> 1.5", optional: true},
      {:ash, "~> 3.24", optional: true},
      {:jason, "~> 1.2", optional: true},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      "defdo.publish": ["local.rebar --force", "local.hex --force", "hex.build"],
      precommit: ["compile --warnings-as-errors", "format", "test"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  defp description do
    "Standard tenant resolution and router plug integration for Defdo host apps."
  end

  defp package do
    [
      organization: @organization,
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Documentation" => "https://hexdocs.pm/defdo_tenant_plug"
      },
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE.md .formatter.exs)
    ]
  end
end
