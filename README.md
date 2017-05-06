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



## More instructions coming soon


In the meantime, most of https://github.com/CultivateHQ/cultivatarmobile/blob/master/README.md, still applies.
