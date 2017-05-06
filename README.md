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

## Documentation todo

- Parts list
- Assembly instructions
- Lego chassis bricks list
- Lego chassis assembly
- Remote shelling in (merge branch  + instructions)
- Suggestions for improvements
- Suggestions for enhancement


... soon
