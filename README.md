# Battlebots

Laser battling robots, takes [The Cultivatormobile](https://github.com/CultivateHQ/cultivatarmobile) with a laser and light sensor so you can play laser tag with your Nerves robots. Two were given as prizes at [ElixirConfEU 2017](http://www.elixirconf.eu/elixirconf2017).

## Instructions for prize receivers

Hopefully you've got your robot home, intact and without any wires coming loose. In order to control the device, though, you'll need to get it onto your won WiFi network. This will involve building this repository.


1. Follow the [Nerves installation instructions](https://hexdocs.pm/nerves/installation.html) for your platform.
1. `cd apps/fw`
1. `cp config/secret.exs.example config/secret.exs`
1. If you are on OS X, you will need to have [Docker installed](https://docs.docker.com/docker-for-mac/).
1. Edit `secret.exs`, adding your WiFi SSID
1. `export MIX_ENV=prod`
1. `export MIX_TARGET=rip0`
1. `mix deps.get`
1. `mix firmware`
1. You'll need to put the micro-sd card into an SD card writer on your computer. (Sorry for not supplying one).
1. `mix firmware.burn`. In my experience this can sometimes require taking the card out and resinserting if you get the error `** (Mix) Could not auto detect your SD card`
1. ???
1. Profit

You can then reinsert the SD card and power up. The PI zero should connect to your WiFi and be listenign on port 80. If you have [nmap](https://nmap.org) installed on your computer, a quick way to scan your local network for listeners on port 80 is given below.


Let's assume your local subnet is `192.168.22.x`

```
nmap -p 80 192.168.22.2-254 | grep -B 4 open
```

## Debugging

Connect a micro-usb *data* cable from your computer to the USB port (not the power port) on the Pi Zero.

`ls /dev/tty.usbmodem*`

Pick the `tty` with the smallest number, eg `/dev/tty/usbmodem1`

`screen /dev/tty.usbmodem1`

Then you'll be connected to the iEX session that the PI boots into.


## Application structure

This is an Elixir Umbrella application, that can be run in `dev` and `test` on a non-linux environment, specifically OS X. From root, or a specific app, you can run `mix test` or `iex -S mix`.

Applications are:

### [`fw`](apps/fw)

Here the [Nerves](YYY) magic takes place. It is from here that the release is built; it also contains some networking related utilities that will only need to run on the target machine. As is now Nerves standard practice, this application will only start if the application is built with the `MIX_TARGET` environment variable set to a value other than empty or `host`.

In addition to being the place from which firmware is created, this application is responsible for connecting to the WiFi network, and setting the system clock via `ntp`; for the latter see [`ntp.ex`](apps/fw/lib/fw/ntp.ex).

WiFi should be configured in [apps/fw/config/secret.exs](apps/fw/config/secret.exs). This file is excluded from source contol, as WiFi connection credentials should be secret.

See [above](YYY) for how to build the firmware, and burn to the sd card.

### [`dummy_nerves`](apps/dummy_nerves)

Contains test-friendly replacements for hardare facing modules, that tend not to compile on OS X. Only build in `dev` and `test`

### [`web`](apps/web)

Runs the simple web interface for controlling the robot. When built for `prod` then it binds port 80; in `dev` port 4000. The interface is vanilla [`Plug`](YYY) over [`cowboy`](YYY).

### [`locomotion`](apps/locomotion)

Controls the stepper motors, through the named `GenServer` [`Locomotion.Locomotion`](apps/cb_locomotion/lib/cb_locomotion/locomotion.ex).

### [`events`](apps/events)


Simple interface for broadcasting and subscribing to application events, via [`Events`](apps/events/lib/events.ex), such as detecting a laser hit.

### [`laser`](apps/laser)

Fires the laser in half-second bursts.

### ['hit_detector'](apps/hit_detector)

Listens to the Arduino (Uno clone) unit, that sends the reading from the photo-sensitive resistor over the serial interface. If a laser hit is detected (by the reading being over 300) then a hit event is broadcast via [`events`](apps/events). (The laser and locomotion contols then become disabled.)

The Arduino code is in [`laser_read.ino`](arduino/laser_read/laser_read.ino).

### ['battle_behaviour'](apps/battle_behaviour)

Contains utilities for disabling controls when the bot is hit, and flashing GPIO pins if (for instance) you want to attach a LED to a pin.


## Development approach

Our general philosophy is that code should be unit-testable, especially when there's a certain amount of logic involved. Consequently `mix test` will work from the root of the umbrella, even if you're developing in OS X. `iex -S mix` will too. We achieve this by, Isolating network related processes in the `fw` application, and selectively only including certain hardware dependencies in when `MIX_ENV` is `prod`.

The Firmware is built from `fw`, and as is now standard *Nerves* practice, the application is only started when `MIX_TARGET` is not "host" (meaning the development machine); there is no attempt to do things like start WiFi or set the system time with `ntp`.

Dependencies like [Elixir ALE](https://github.com/fhunleth/elixir_ale) will not compile on OS X so are only included when compiling for `prod`. Replacement modules are supplied in the app `dummy_nerves`. eg, from deps  in [`laser/mix.exs`](apps/laser/mix.exs):

```
 {:elixir_ale, "~> 0.6.2", only: :prod},
 {:dummy_nerves, in_umbrella: true, only: [:dev, :test]},
```


## Parts

Parts listed are from UK suppliers, but you should be able to find something similar wherever you are. [Joel Byler](https://twitter.com/joelbyler) put together an Amazon whishlist for the relatated [Cultivatormobile project](https://github.com/CultivateHQ/cultivatarmobile): https://www.amazon.com/registry/wishlist/1RB8HLPX63U1Q/ref=cm_sw_r_tw_ws_x_N6P4xb8ZN9RGN .



| Part | Available from |
|------|----------------|
| Pi Zero W) | PI Hut: https://thepihut.com/products/raspberry-pi-zero-w?variant=30332705425, or Pimoroni: https://shop.pimoroni.com/products/raspberry-pi-zero-w. Note that stocks are limited to one per customer. |
| 40-pin 2x20 male headers for the Gpio | eg https://shop.pimoroni.com/products/male-40-pin-2x20-hat-header or the solderless  https://shop.pimoroni.com/products/gpio-hammer-header (not tried)|
| Female / Female jumper cables | At least 15, eg from https://www.amazon.co.uk/gp/product/B00OL6JZ3C/ |
| 5v power bank (portable phone charger) | Something like https://www.amazon.co.uk/gp/product/B00VJS9R4C. They should come with a USB to micro USB cable to connect to the PI |
| Micro SD card, at least 4GB | Bigger is ok. eg https://www.amazon.co.uk/Kingston-8GB-Micro-SD-HC/dp/B001CQT0X4/ |
| 2 x 28Byj stepper motors with ULN2003 controllers | eg 5 pieces from here https://www.amazon.co.uk/gp/product/B00SSQAITQ |
| Battery for stepper motors | For the giveaway we a used battery holder for 4 AA batteries, https://www.amazon.co.uk/gp/product/B00XHQ18DW. You need to provide between 5v and 12v to the steppers |
| Wheels | 4tronix, a UK company, sell wheels that fit the stepper motors http://4tronix.co.uk/store/index.php?rt=product/product&keyword=wheels&category_id=0&product_id=176. Alternatively here's some 3D printing files that I have found http://www.thingiverse.com/thing:862438 |
| Lasers | eg https://www.amazon.co.uk/gp/product/B00JWJ1Y8W/, soldered to female jumper cables |
| Light sensors | These were self assembled using [Photoresistors](https://www.amazon.co.uk/gp/product/B01N7V536K), 100 ohm, resistors, bits of [Veroboard](https://www.amazon.co.uk/Copper-strip-prototyping-veroboard-64x95mm/dp/B01C5TB3L8) cut with a Stanely knife. |
| Shrimp Arduino| These kits are available from [Shrimping It](http://start.shrimping.it) |

Note that the current reason for using the Arduino uints was to read the analogue values from the photoresistor. A simpler alternative, that we did not follow because of delivery times, might be connecing a [MCP 3008](https://www.amazon.co.uk/Adafruit-MCP3008-856-Converter-Interface/dp/B00NAY3RB2/) chip over [SPI](https://github.com/fhunleth/elixir_ale/blob/master/lib/elixir_ale/spi.ex).


## Chassis

The chassis was assembled from lego.

Todo: brick list.



## Assembly

### PI Zero headers

todo

### Chassis

todo

### Motors and wheels

todo

### Connecting motors to PI and Batteries

todo

### Soldering the photoresistor units together

todo

### Assembling and connecting the Shrimp Arduino

todo


## Todo


- Suggestions for improvements (eg control steppers via Arduino)
- Suggestions for enhancement (eg more sensors. Recharge period for battery)


... soon
