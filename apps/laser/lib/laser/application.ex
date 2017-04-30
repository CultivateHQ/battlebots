defmodule Laser.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Laser.LaserControl, [5, 500, :real_laser]),
      worker(BattleBehaviour.BattleProxy, [:real_laser, [name: Laser.LaserControl]])
    ]

    opts = [strategy: :one_for_one, name: Laser.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
