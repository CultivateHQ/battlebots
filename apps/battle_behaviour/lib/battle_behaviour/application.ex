defmodule BattleBehaviour.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(BattleBehaviour.ReactionPinSupervisor, []),
    ]

    opts = [strategy: :one_for_one, name: BattleBehaviour.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
