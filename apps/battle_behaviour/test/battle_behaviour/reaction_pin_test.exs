defmodule BattleBehaviour.ReactionPinTest do
  use ExUnit.Case

  alias BattleBehaviour.ReactionPin

  alias ElixirALE.GPIO

  setup do
    {:ok, pid} = ReactionPin.start_link(55)
    pin_pid = :sys.get_state(pid).pin_pid
    {:ok, pid: pid, pin_pid: pin_pid}
  end

  test "pins initialised to zero", %{pin_pid: pin_pid} do
    assert GPIO.pin_state_log(pin_pid) == [0]
  end
end
