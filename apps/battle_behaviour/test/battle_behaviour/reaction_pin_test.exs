defmodule BattleBehaviour.ReactionPinTest do
  use ExUnit.Case

  alias BattleBehaviour.ReactionPin

  alias ElixirALE.GPIO

  setup do
    {:ok, pid} = ReactionPin.start_link(55, 0)
    pin_pid = :sys.get_state(pid).pin_pid
    {:ok, pid: pid, pin_pid: pin_pid}
  end

  test "pins initialised to zero", %{pin_pid: pin_pid} do
    assert GPIO.pin_state_log(pin_pid) == [0]
  end

  test "pins flashed on and off when hit", %{pid: pid, pin_pid: pin_pid} do
    send(pid, {:battle_event, :laser_hits, :hit})
    assert :sys.get_state(pid).hit
    wait_for_flashing(pin_pid)
  end

  test "pins not flashed if not hit", %{pid: pid, pin_pid: pin_pid} do
    send(pid, :flash_on)
    send(pid, :flash_off)
    :sys.get_state(pid)
    assert GPIO.pin_state_log(pin_pid) == [0]
  end

  test "flashed off and not hit if reset", %{pid: pid, pin_pid: pin_pid} do
    send(pid, {:battle_event, :laser_hits, :hit})
    send(pid, {:battle_event, :laser_hits, :reset})
    refute :sys.get_state(pid).hit
    assert GPIO.read(pin_pid) == 0
  end

  defp wait_for_flashing(pin_pid) do
    wait_for_flashing(pin_pid, 100)
  end

  defp wait_for_flashing(pin_pid, 0) do
    flunk "didn't flash: #{inspect(GPIO.pin_state_log(pin_pid))}"
  end

  defp wait_for_flashing(pin_pid, count) do
    case GPIO.pin_state_log(pin_pid) do
      [0, 1, 0, 1 | _] ->
        # yay!
        true
      _ ->
        :timer.sleep(1)
        wait_for_flashing(pin_pid, count - 1)
    end
  end



end
