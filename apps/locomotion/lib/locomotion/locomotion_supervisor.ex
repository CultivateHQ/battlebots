defmodule Locomotion.LocomotionSupervisor do
  @moduledoc """
  Supervises the StepperMotors and the Locomotion interface.

  Uses `one_for_all`: if anything goes down, then it all comes back
  up again in a known good state, ie the initial motionless state.
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Locomotion.StepperMotor, [stepper_pins()[:right], [name: :right_stepper]], id: :left),
      worker(Locomotion.StepperMotor, [stepper_pins()[:left], [name: :left_stepper]], id: :right),
      worker(Locomotion.Locomotion, []),
    ]

    supervise(children, strategy: :one_for_all)
  end


  defp stepper_pins do
    Application.fetch_env!(:locomotion, :steppers)
  end
end
