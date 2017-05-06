defmodule BattleBehaviour.ReactionPin do
  @moduledoc """
  Flashes a pin on, and off, when hit. Ideal for attaching to a LED.
  """

  use GenServer

  alias ElixirALE.GPIO

  @delay 250

  defstruct pin_pid: nil, delay: nil, hit: false

  def start_link(pin, delay \\ @delay) do
    GenServer.start_link(__MODULE__, {pin, delay}, name: :"reacton_#{pin}")
  end

  def init({pin, delay}) do
    {:ok, pid} = GPIO.start_link(pin, :output)
    Events.subscribe(:laser_hits)

    GPIO.write(pid, 0)

    {:ok, %__MODULE__{pin_pid: pid, delay: delay}}
  end

  def handle_info({:battle_event, :laser_hits, :hit}, s = %{hit: false}) do
    send(self(), :flash_on)
    {:noreply, %{s | hit: true}}
  end

  def handle_info({:battle_event, :laser_hits, :reset}, s = %{pin_pid: pin_pid}) do
    GPIO.write(pin_pid, 0)
    {:noreply, %{s | hit: false}}
  end

  def handle_info(:flash_on, s = %{hit: true, pin_pid: pin_pid}) do
    GPIO.write(pin_pid, 1)
    send(self(), :flash_off)
    {:noreply, s}
  end

  def handle_info(:flash_off, s = %{hit: true, pin_pid: pin_pid}) do
    GPIO.write(pin_pid, 0)
    send(self(), :flash_on)
    {:noreply, s}
  end

  def handle_info(_other, s), do: {:noreply, s}
end
