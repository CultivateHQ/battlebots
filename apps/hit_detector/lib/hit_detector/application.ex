defmodule HitDetector.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(HitDetector.HitDetect, [serial_port(), trigger_threshold()])
    ]

    opts = [strategy: :one_for_one, name: HitDetector.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp serial_port do
    Application.fetch_env!(:hit_detector, :serial_port)
  end

  defp trigger_threshold do
    Application.fetch_env!(:hit_detector, :trigger_threshold)
  end
end
