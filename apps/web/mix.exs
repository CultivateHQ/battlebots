defmodule Web.Mixfile do
  use Mix.Project

  def project do
    [app: :web,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Web.Application, []}]
  end

  defp deps do
    [
      {:plug, ">= 0.0.0"},
      {:cowboy, ">= 0.0.0"},
      {:locomotion, in_umbrella: true},
    ]
  end
end
