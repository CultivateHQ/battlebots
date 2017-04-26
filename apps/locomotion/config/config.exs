use Mix.Config

config :locomotion, :steppers, [right: [21, 20, 16, 12],
                                left: [26, 19, 13, 6]]
config :locomotion, :gpio_pins_to_test, 2..27

#     import_config "#{Mix.env}.exs"
