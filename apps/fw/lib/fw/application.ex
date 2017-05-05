defmodule Fw.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Nerves.InterimWiFi, ["wlan0", wifi_opts()], function: :setup),
      worker(Fw.Ntp, []),
      worker(Fw.DistributeNode, []),
    ]

    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp wifi_opts, do: Application.fetch_env!(:fw, :wifi_opts)
end
