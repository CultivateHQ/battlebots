use Mix.Config

config :hit_detector, :serial_port, "/dev/cu.SLAB_USBtoUART"
config :hit_detector, :trigger_threshold, 300


# config :hit_detector, :hit_pin, 18
#
import_config "#{Mix.env}.exs"
