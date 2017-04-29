defmodule Events.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:duplicate,  :events_registry]),
    ]

    opts = [strategy: :one_for_one, name: Events.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
