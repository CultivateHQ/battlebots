defmodule HitDetector.Mixfile do
  use Mix.Project

  @uart_in_dev? System.get_env("DEV_UART") == "true" || false

  def project do
    [app: :hit_detector,
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
     mod: {HitDetector.Application, []}]
  end

  defp deps do
    [
      {:nerves_uart, "~> 0.1.0", only: nerves_uart_only(@uart_in_dev?)},
      {:events, in_umbrella: true},
      {:dummy_nerves, in_umbrella: true, only: dummy_nerves_only(@uart_in_dev?)},
    ]
  end

  defp nerves_uart_only(true), do: [:dev, :prod]
  defp nerves_uart_only(false), do: [:prod]

  defp dummy_nerves_only(true), do: [:test]
  defp dummy_nerves_only(false), do: [:dev, :test]

end
