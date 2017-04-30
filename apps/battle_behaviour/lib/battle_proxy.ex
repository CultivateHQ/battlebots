defmodule BattleProxy do
  use GenServer

  @moduledoc """
  Sits in fron of other GenServers and passes on `cast` and `call` messages under normal circumstances.

  Subscribes to events and blocks messages after a laser hit. Works again after receiving a reset.
  """

  defstruct actual: nil, enabled: true

  def start_link(actual, opts) do
    GenServer.start_link(__MODULE__, {actual}, opts)
  end

  def init({actual}) do
    Events.subscribe(:laser_hits)
    {:ok, %__MODULE__{actual: actual}}
  end

  def handle_cast(_, s = %{enabled: false}), do: {:noreply, s}
  def handle_cast(action, s = %{actual: actual}) do
    GenServer.cast(actual, action)
    {:noreply, s}
  end

  def handle_call(_, _, s = %{enabled: false}), do: {:reply, {:error, :disabled_by_laser}, s}
  def handle_call(action, _from, s = %{actual: actual}) do
    reply = GenServer.call(actual, action)
    {:reply, reply, s}
  end

  def handle_info({:battle_event, :laser_hits, :hit}, s) do
    {:noreply, %{s | enabled: false}}
  end

  def handle_info({:battle_event, :laser_hits, :reset}, s) do
    {:noreply, %{s | enabled: true}}
  end
end
