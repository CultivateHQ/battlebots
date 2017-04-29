defmodule EventsTest do
  use ExUnit.Case
  doctest Events

  test "subscribing and receiving events" do
    Events.subscribe(:laser_hits)

    Events.broadcast(:laser_hits, "pweep pweep")

    assert_receive {:battle_event, :laser_hits, "pweep pweep"}
  end
end
