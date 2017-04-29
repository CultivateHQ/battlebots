defmodule Nerves.UART do
  use GenServer

  defstruct port: nil, client: nil

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    {:ok, %__MODULE__{}}
  end

  def open(pid, port, opts) do
    case Keyword.get(opts, :active) do
      true ->
        GenServer.call(pid, {:open, port})
      _ -> {:error, :active_only_supported}
    end
    :ok
  end

  def pretend_to_receive(pid, msg) do
    GenServer.call(pid, {:pretend_to_receive, msg})
  end

  def handle_call({:open, port}, {from, _}, s) do
    {:reply, :ok, %{s | port: port, client: from}}
  end

  def handle_call({:pretend_to_receive, msg}, _from, s = %{port: port, client: client}) do
    send(client, {:nerves_uart, port, msg})
    {:reply, :ok, s}
  end
end
