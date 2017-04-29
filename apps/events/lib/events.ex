defmodule Events do
  @moduledoc """
  Enables a process to subscribe to events on a topic, and for
  events to be broadcat to a topic
  """

  @valid_topics [:laser_hits, :network_ready]

  @doc """
  Subscribe the current process to the topic
  """
  def subscribe(topic) when topic in @valid_topics do
    Registry.register(:events_registry, topic, [])
  end

  @doc """
  Broadcast an event to the topic. The topic receives
  {:battle_event, topic, event}
  """
  def broadcast(topic, event)  when topic in @valid_topics do
    Registry.dispatch(:events_registry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:battle_event, topic, event})
    end)
  end
end
