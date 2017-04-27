defmodule Laser.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Laser.Laser, [5])
    ]

    opts = [strategy: :one_for_one, name: Laser.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
