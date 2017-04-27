defmodule Laser.LaserControl do
  use GenServer

  alias ElixirALE.GPIO

  @name __MODULE__
  @fire_time 500


  defstruct pin_pid: nil, firing: false, fire_time: nil

  def start_link(laser_pin, fire_time \\ @fire_time, name \\ @name) when is_integer(laser_pin) do
    GenServer.start_link(__MODULE__, {laser_pin, fire_time}, name: name)
  end

  def init({laser_pin, fire_time}) do
    {:ok, pin_pid} = GPIO.start_link(laser_pin, :output)
    GPIO.write(pin_pid, 1)

    # Some naughty thing sets the state back to 0 after about 200ms. Horrid workaround ahead:
    Process.send_after(self(), :cease_fire, 500)

    {:ok, %__MODULE__{pin_pid: pin_pid, fire_time: fire_time}}
  end

  def fire(pid \\ @name) do
    GenServer.cast(pid, :fire)
    :ok
  end

  def handle_cast(:fire, s = %{firing: true}), do: {:noreply, s}
  def handle_cast(:fire, s = %{firing: false,
                               pin_pid: pin_pid,
                               fire_time: fire_time}) do
    GPIO.write(pin_pid, 0)
    Process.send_after(self(), :cease_fire, fire_time)
    {:noreply, %{s | firing: true}}
  end

  def handle_info(:cease_fire, s = %{pin_pid: pin_pid}) do
    GPIO.write(pin_pid, 1)
    {:noreply, %{s | firing: false}}
  end
end
