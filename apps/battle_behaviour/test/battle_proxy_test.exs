defmodule BattleProxyTest do
  use ExUnit.Case

  defmodule AGenServer do
    use GenServer

    defstruct count: 0

    def start_link do
      GenServer.start_link(__MODULE__, {})
    end

    def init(_), do: {:ok, %__MODULE__{}}

    def increment(pid), do: GenServer.cast(pid, :increment)
    def count(pid), do: GenServer.call(pid, :count)

    def handle_cast(:increment, s = %{count: count}), do: {:noreply, %{s | count: count + 1}}
    def handle_call(:count, _from, s = %{count: count}), do: {:reply, count, s}
  end

  setup do
    {:ok, actual} = AGenServer.start_link
    {:ok, proxy} = BattleProxy.start_link(actual, [])


    {:ok, actual: actual, proxy: proxy}
  end

  test "test proxying", %{proxy: proxy} do
    assert :ok == AGenServer.increment(proxy)
    assert AGenServer.count(proxy) == 1
  end

  test "test shuts down after laser hit", %{proxy: proxy, actual: actual} do
    Events.broadcast(:laser_hits, :hit)
    AGenServer.increment(proxy)

    assert AGenServer.count(proxy) == {:error, :disabled_by_laser}
    assert AGenServer.count(actual) == 0
  end

  test "resetting after shutdown", %{proxy: proxy} do
    Events.broadcast(:laser_hits, :hit)
    Events.broadcast(:laser_hits, :reset)

    assert AGenServer.increment(proxy)
    assert AGenServer.count(proxy) == 1
  end
end
