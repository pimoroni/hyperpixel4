# HyperPixel 4.0" Square Drivers for Raspberry Pi 4

HyperPixel 4.0 Square is an 720x720 pixel display for the Raspberry Pi, with optional capacitive touchscreen.

## Installing / Uninstalling

First, clone this GitHub repository branch to your Pi:

```
git clone https://github.com/pimoroni/hyperpixel4 -b square-pi4
```

Then run the installer to install:

```
cd hyperpixel4
sudo ./install.sh
```

## Rotation

It's square. Just turn it around.

On Pi 4 we can take advantage of the rotation available in Display Configuration, and provide you with a command for setting both display and touch rotation together.

To rotate HyperPixel4 on a Pi 4 use the `hyperpixel4-rotate` command.

```
hyperpixel4-rotate left
hyperpixel4-rotate left
hyperpixel4-rotate normal
hyperpixel4-rotate inverted
```

If you're running this command over SSH you should prefix it with `DISPLAY=:0.0`
