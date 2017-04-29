defmodule HitDetector.HitDetect do
  use GenServer

  alias Nerves.UART
  require Logger

  @name __MODULE__

  defstruct trigger_threshold: 0, uart_pid: nil


  def start_link(serial_port, trigger_threshold) do
    GenServer.start_link(__MODULE__, {serial_port, trigger_threshold}, name: @name)
  end


  def init({serial_port, trigger_threshold}) do
    {:ok, pid} = UART.start_link
    :ok = UART.open(pid, serial_port,
      speed: 115200,
      active: true,
      framing: {Nerves.UART.Framing.Line, separator: "\r\n"},)


    {:ok, %__MODULE__{uart_pid: pid, trigger_threshold: trigger_threshold}}
  end

  def handle_info({:nerves_uart, _serial_port, message}, s = %{trigger_threshold: threshold}) do
    handle_serial_message(message, threshold)
    {:noreply, s}
  end

  defp handle_serial_message("LS:" <> value, threshold) do
    case Integer.parse(value) do
      {int_value, _} -> handle_sensor_value(int_value, threshold)
      err ->
        Logger.error "Bad light sensor value received: #{inspect {value, err}}"
    end
  end
  defp handle_serial_message(message, _) do
    Logger.info "Serial message received: #{message}"
  end

  defp handle_sensor_value(value, threshold) when value > threshold do
    Events.broadcast(:laser_hits, :hit)
  end
  defp handle_sensor_value(_value, _theshold), do: nil
end
