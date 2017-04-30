defmodule Laser.Mixfile do
  use Mix.Project

  def project do
    [app: :laser,
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
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Laser.Application, []}]
  end

  defp deps do
    [
      {:events, in_umbrella: true},
      {:battle_behaviour, in_umbrella: true},
      {:elixir_ale, "~> 0.6.2", only: :prod},
      {:dummy_nerves, in_umbrella: true, only: [:dev, :test]},
    ]
  end
end
