defmodule BattleBehaviour.ReactionPin do
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

    {:ok, %__MODULE__{pin_pid: pid, delay: delay}}
  end

  def handle_info({:battle_event, :laser_hits, :hit}, s) do
    {:noreply, s}
  end

  def handle_info({:battle_event, :laser_hits, :reset}, s) do
    {:noreply, s}
  end

  def handle_info(_other, s), do: {:noreply, s}
end
