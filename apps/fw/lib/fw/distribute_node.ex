defmodule Fw.DistributeNode do
  use GenServer

  @name __MODULE__

  defstruct ipv4_address: nil

  # 00:02:48.336 [debug] {Nerves.Udhcpc, :bound, %{domain: "", ifname: "wlan0", ipv4_address: "192.168.22.102", ipv4_broadcast: "", ipv4_gateway: "192.168.22.1", ipv4_subnet_mask: "255.255.255.0", nameservers: ["192.168.22.1"]}}


  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init(_) do
    System.cmd("epmd", ["-daemon"])
    {:ok, _} =  Registry.register(Nerves.Udhcpc, "wlan0", [])
    {:ok, %__MODULE__{}}
  end

  def handle_info({Nerves.Udhcpc, :bound, %{ipv4_address: address}}, s) do
    Events.broadcast(:network_ready, {:ip_addr_received, address})
    send(self(), :ip_address_received)

    {:noreply, %{s | ipv4_address: address}}
  end

  def handle_info(:ip_address_received, s = %{ipv4_address: address}) do
    Node.stop
    full_node_name = "battlebot@#{address}" |> String.to_atom
    {:ok, _pid} = Node.start(full_node_name)

    {:noreply, s}
  end


  def handle_info(msg, s) do
    Logger.debug "***************************"
    Logger.debug inspect(msg)
    Logger.debug "***************************"
    {:noreply, s}
  end
end
