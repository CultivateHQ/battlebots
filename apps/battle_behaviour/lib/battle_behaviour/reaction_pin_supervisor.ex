defmodule BattleBehaviour.ReactionPinSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def init(_) do
    pins = Application.fetch_env!(:battle_behaviour, :reaction_pins)
    children = for pin <- pins, do: worker(BattleBehaviour.ReactionPin, [pin], id: :"reaction#{pin}")
    supervise(children, strategy: :one_for_one)
  end
end
