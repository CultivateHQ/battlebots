defmodule Locomotion.ReactToLaserTest do
  use ExUnit.Case
  alias Locomotion.StepperMotor

  test "robot turns left when hit" do
    Events.broadcast(:laser_hits, :hit)
    :timer.sleep(1)

    assert StepperMotor.state(:right_stepper).direction == :forward
    assert StepperMotor.state(:left_stepper).direction == :forward
  end

  test "robot stops when reset" do
    Events.broadcast(:laser_hits, :hit)
    Events.broadcast(:laser_hits, :reset)
    :timer.sleep(1)

    assert StepperMotor.state(:right_stepper).direction == :neutral
    assert StepperMotor.state(:left_stepper).direction == :neutral
  end
end
