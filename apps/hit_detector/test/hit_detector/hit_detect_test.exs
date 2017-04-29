defmodule HitDetector.HitDetectTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias HitDetector.HitDetect
  alias Nerves.UART

  setup do
    %{uart_pid: uart_pid} = :sys.get_state(HitDetect)

    Events.subscribe(:laser_hits)

    {:ok, uart_pid: uart_pid}
  end

  test "hit detected if above the threshold", %{uart_pid: uart_pid} do
    UART.pretend_to_receive(uart_pid, "LS:#{301}")

    assert_receive {:battle_event, :laser_hits, :hit}
  end

  test "hit not detected if below the threshold", %{uart_pid: uart_pid} do
    UART.pretend_to_receive(uart_pid, "LS:#{300}")

    do_not_receive_event()

  end

  test "garbled (non-int) values logged then ignored", %{uart_pid: uart_pid} do
    fun = fn ->
      UART.pretend_to_receive(uart_pid, "LS:aaaargh!")
      do_not_receive_event()
    end
    assert capture_log(fun) =~ "[error]"
  end

  test "other values logged and ignored", %{uart_pid: uart_pid} do
    fun = fn ->
      UART.pretend_to_receive(uart_pid, "Hello matey")
      do_not_receive_event()
    end
    assert capture_log(fun) =~ "[info]"
  end

  defp do_not_receive_event do
    receive do
      {:battle_event, :laser_hits, :hit} -> flunk "Should not have received hit event"
      wtf -> flunk "Unexpected event: #{wtf}"
    after
      100 ->
        # Expected
        nil
    end
  end
end
