defmodule Laser.LaserControlTest do
  use ExUnit.Case
  alias Laser.LaserControl
  alias ElixirALE.GPIO


  setup do
    {:ok, pid} = LaserControl.start_link(7, 1, :laser_controller_test)
    {:ok, gpio_7} = GPIO.start_link(7, :output)
    {:ok, laser: pid, pin: gpio_7}
  end

  test "is initially set to high", %{pin: pin} do
    assert GPIO.read(pin) == 1
  end

  test "firing sets pin to low", %{pin: pin, laser: laser} do
    LaserControl.fire(laser)
    :sys.get_state(laser)
    assert GPIO.read(pin) == 0
    wait_for_pin_state(pin, 1, 100)
  end

  defp wait_for_pin_state(_pin, expected_state, 0) do
    flunk "Pin did not achieve state #{expected_state}"
  end
  defp wait_for_pin_state(pin, expected_state, wait_iterations) do
    Process.sleep(1)
    if GPIO.read(pin) != expected_state, do: wait_for_pin_state(pin, expected_state, wait_iterations - 1)
  end
end
