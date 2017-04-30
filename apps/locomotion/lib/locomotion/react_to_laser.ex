defmodule Locomotion.ReactToLaser do
  use GenServer

  defstruct real_locomotion: nil

  @name __MODULE__

  def start_link(real_locomotion) do
    GenServer.start_link(__MODULE__, real_locomotion, name: @name)
  end

  def init(real_locomotion) do
    Events.subscribe(:laser_hits)

    {:ok, %__MODULE__{real_locomotion: real_locomotion}}
  end

  def handle_info({:battle_event, :laser_hits, :hit}, s = %{real_locomotion: real_locomotion}) do
    GenServer.call(real_locomotion, :turn_left)
    {:noreply, s}
  end

  def handle_info({:battle_event, :laser_hits, :reset}, s = %{real_locomotion: real_locomotion}) do
    GenServer.call(real_locomotion, :stop)
    {:noreply, s}
  end

  def handle_info(_, s), do: {:noreply, s}
end
