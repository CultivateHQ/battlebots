defmodule GPIOTest do
  use ExUnit.Case

  alias ElixirALE.GPIO

  setup do
    {:ok, pid} = GPIO.start_link(6, :output)
    GPIO.reset_pin_states(pid)
    {:ok, pin6: pid}
  end

  test "reading and writing", %{pin6: pin6} do
    assert 0 == GPIO.read(pin6)
    GPIO.write(pin6, 1)
    assert 1 == GPIO.read(pin6)
    GPIO.write(pin6, 0)
    assert 0 == GPIO.read(pin6)

    GPIO.write(pin6, 1)
    GPIO.reset_pin_states(pin6)
    assert 0 == GPIO.read(pin6)
  end

  test 'logging', %{pin6: pin6} do
    assert [] == GPIO.pin_state_log(pin6)
    GPIO.write(pin6, 1)
    GPIO.write(pin6, 0)
    GPIO.write(pin6, 0)
    GPIO.write(pin6, 1)
    GPIO.write(pin6, 1)
    assert [1, 0, 0, 1, 1] == GPIO.pin_state_log(pin6)
    GPIO.reset_pin_states(pin6)
    assert [] == GPIO.pin_state_log(pin6)
  end

  test "asking for the same pin twice", %{pin6: pin6} do
    # For neatness, each dummy GPIO is by default named after the pin which
    # could cause issues if a pin is used in different parts of the app.
    {:ok, pin6clone} = GPIO.start_link(6, :input)
    {:ok, pin7} = GPIO.start_link(7, :input)

    assert pin6 == pin6clone
    assert pin6 == Process.whereis(:gpio_6)
    refute pin7 == pin6
  end
end
