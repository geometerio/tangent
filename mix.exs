defmodule Tangent.MixProject do
  use Mix.Project

  @scm_url "https://github.com/geometerio/tangent"
  @version "0.1.0"
  def project do
    [
      app: :tangent,
      deps: deps(),
      description: "Checks for setting up development environments",
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.12",
      homepage_url: @scm_url,
      name: "Tangent",
      package: package(),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application,
    do: [
      extra_applications: [:logger]
    ]

  defp deps,
    do: [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 0.1", only: [:dev, :test], runtime: false}
    ]

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      extras: [
        "guides/overview.md"
      ],
      main: "overview",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Geometer"],
      links: %{"GitHub" => @scm_url}
    ]
  end
end
