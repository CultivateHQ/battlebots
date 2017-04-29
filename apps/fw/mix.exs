defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"
  Mix.shell.info([:green, """
  Env
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])
  def project do
    [app: :fw,
     version: "0.1.0",
     elixir: "~> 1.4.0",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.3.0"],
     deps_path: "../../deps/#{@target}",
     build_path: "../../_build/#{@target}",
     config_path: "../../config/config.exs",
     lockfile: "../../mix.lock",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(@target),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  def application, do: application(@target)

  def application("host") do
    [extra_applications: [:logger]]
  end
  def application(_target) do
    [mod: {Fw.Application, []},
     extra_applications: [:logger]]
  end

  def deps do
    [
      {:nerves, github: "nerves-project/nerves", runtime: false, override: true},
      # {:nerves, "~> 0.5.1", runtime: false},
      {:locomotion, in_umbrella: true},
      {:laser, in_umbrella: true},
      {:web, in_umbrella: true},
      {:hit_detector, in_umbrella: true},
    ] ++
    deps(@target)
  end

  # Specify target specific dependencies
  def deps("host"), do: []
  def deps("rpi0" = _target) do
    [
      {:nerves_runtime, "~> 0.1.0"},
      {:nerves_interim_wifi, "~> 0.2.0"},
      # {:"nerves_system_#{target}", ">= 0.0.0", runtime: false},
      # {:nerves_system_rpi0, path: "../../../nerves_system_rpi0", runtime: false},
      # {:nerves_system_rpi0, github: "nerves-project/nerves_system_rpi0", tag: "v0.11.1", runtime: false},
      # {:"rpi0_gadget_ethernet", github: "tmecklem/rpi0_gadget_ethernet", tag: "v0.12.0", runtime: false},
      {:nerves_system_rpi0, github: "paulanthonywilson/nerves_system_rpi0", runtime: false},
    ]
  end

  # We do not invoke the Nerves Env when running on the Host
  def aliases("host"), do: []
  def aliases(_target) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
