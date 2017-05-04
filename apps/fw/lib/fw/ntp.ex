defmodule Fw.Ntp do
  @doc """
  `ntpd` can be used to set time, but it now no longer returns if it cannot resolve the timeserver.
  This can be a problem is the network isn't up yet.
  """

  @name __MODULE__

  @poll_after_time_set :timer.minutes(30)
  @poll_after_not_set :timer.seconds(1)

  require Logger

  defstruct ntp_args: nil, first_server: nil, time_set: true

  def start_link(ntp_servers \\ ["0.pool.ntp.org",
                                 "1.pool.ntp.org",
                                 "2.pool.ntp.org",
                                 "3.pool.ntp.org"]) do
    GenServer.start_link(__MODULE__, ntp_servers, name: @name)
  end

  def init(ntp_servers = [first_server | _]) do
    send(self(), :poll)
    {:ok, %__MODULE__{first_server: String.to_charlist(first_server),
                      ntp_args: ["-n", "-q", "-p" | ntp_servers]}}
  end

  def handle_info(:poll, s = %{first_server: first_server, ntp_args: ntp_args}) do
    repoll = case :inet.gethostbyname(first_server) do
      {:ok, _} ->
        Logger.info("About to set time")
        System.cmd("ntpd", ntp_args)
        @poll_after_time_set
      _ ->
        # Logger.debug("Not ready to set time, yet")
        @poll_after_not_set
    end
    Process.send_after(self(), :poll, repoll)
    {:noreply, s}
  end
end
