# HyperPixel 4.0" Drivers

HyperPixel 4.0 is an 800x480 or 720x720 pixel display for the Raspberry Pi, with optional capacitive touchscreen.

## Installing / Uninstalling

This repository contains several branches for different combinations of Pi and HyperPixel4 boards.

You should use our one-line installer to install HyperPixel4 Rectangular and Square:

```
curl -sSL https://get.pimoroni.com/hyperpixel4 | bash
```

When prompted, pick the combination of Pi and touchscreen that you're planning to use.

Note: A HyperPixel4 setup for Pi 3B+ or earlier will not readily work if you move it over to a Pi 4, you should run this installer again to update the drivers.

### Manual Installation

Here's a list of active branches and which Pi/display combination they support:

* [pi3](https://github.com/pimoroni/hyperpixel4/tree/pi3) - Pi 3B+ and earlier, HyperPixel4 Rectangular
* [pi4](https://github.com/pimoroni/hyperpixel4/tree/pi4) - Pi 4, HyperPixel4 Rectangular, use `hyperpixel4-rotate` to rotate once installed
* [square](https://github.com/pimoroni/hyperpixel4/tree/square) - Pi 3B+ and earlier, HyperPixel4 Square
* [square-pi4](https://github.com/pimoroni/hyperpixel4/tree/square-pi4)  - Pi 4, HyperPixel4 Square

To clone a specific branch to your Pi, run:

```
git clone https://github.com/pimoroni/hyperpixel4 -b <branch name>
```

Then `cd hyperpixel4` and run `sudo ./install.sh` to install it.

## Rotation

### Rotation on Pi 4

HyperPixel4 is a portait display, so on first boot it will start in portrait mode with the USB ports at the top.

On Pi 4 we can take advantage of the rotation available in Display Configuration, and provide you with a command for setting both display and touch rotation together.

To rotate HyperPixel4 on a Pi 4 use the `hyperpixel4-rotate` command.

Landscape mode, HDMI/power ports on the bottom:

```
hyperpixel4-rotate left
```

Landscape mode, HDMI/power ports on the top:
  
```
hyperpixel4-rotate right
```

Portrait mode, USB ports on the top:

```
hyperpixel4-rotate normal
```

Portrait mode, USB ports on the bottom:

```
hyperpixel4-rotate inverted
```

If you're running this command over SSH you should prefix it with `DISPLAY=:0.0`

#### 180 Degree Rotation on Pi 3

Note: You *must* build the latest dtoverlay file to enable rotation support:

1. Go into `src`
2. run `make` to build a new hyperpixel4.dtbo with rotation support
3. copy the overlay with `sudo cp hyperpixel4.dtbo /boot/overlays/`

To rotate your HyperPixel4 you must edit /boot/config.txt and change the following lines:

1. Change `dtoverlay=hyperpixel4` to `dtoverlay=hyperpixel4:rotate`
2. Change `display_rotate=3` to `display_rotate=1`

This will rotate both the display and the touchscreen input to match.

If you're using a non-touchscreen HyperPixel4 you need only change `display_rotate`.

## Troubleshooting

Where possible we are collecting known FAQs under the `notice` label in our issue tracker.

[`Notice` Issue Tracker](https://github.com/pimoroni/hyperpixel4/issues?q=is%3Aissue+label%3Anotice+)

If your issue is not covered by one of these provided by our team and community 
then we ask you to provide some debugging information using the following oneliner:

```bash
curl -sSL https://raw.githubusercontent.com/pimoroni/hyperpixel4/master/hyperpixel4-debug.sh | bash
```

Then [file a bug report](https://github.com/pimoroni/hyperpixel4/issues/new/choose).


