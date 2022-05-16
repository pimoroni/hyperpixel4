# HyperPixel 4.0" Drivers

HyperPixel 4.0 is an 800x480 or 720x720 pixel DPI display for Raspberry Pi, with optional capacitive touchscreen. The drivers/instructions in this repo are written for and tested with Raspberry Pi OS, and are not guaranteed to work with other operating systems.

## Installing / Uninstalling (Bullseye / Linux Kernel 5.15 or later)

Raspberry Pi OS Bullseye includes major changes to how DPI display drivers work. If you're using an image dated 04/04/2022 or later, it will come with Hyperpixel drivers baked in and you don't need to run the legacy installer. You can set up display and touch by adding a few lines to your boot/config.txt:

[PSA: HyperPixel 4 (Square & Rectangular) on Raspberry Pi OS 2022-04-04](https://github.com/pimoroni/hyperpixel4/issues/177)

⚠️Note that touch rotation commands will not currently work with on the square variant, and that the current kernel drivers will only work with newer square boards (marked Hyperpixel XP).

## Installing / Uninstalling (Legacy)

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
* [pi4](https://github.com/pimoroni/hyperpixel4/tree/pi4) - Pi 4 & Pi 400, HyperPixel4 Rectangular, use `hyperpixel4-rotate` to rotate once installed
* [square](https://github.com/pimoroni/hyperpixel4/tree/square) - Pi 3B+ and earlier, HyperPixel4 Square (for boards manufactured 2020 and earlier)
* [square-pi4](https://github.com/pimoroni/hyperpixel4/tree/square-pi4)  - Pi 4 & Pi 400, HyperPixel4 Square (for boards manufactured 2020 and earlier)
* [square-2021](https://github.com/pimoroni/hyperpixel4/tree/square-2021) - Pi 3B+ and earlier, HyperPixel4 Square (for boards manufactured 2021 and later)
* [square-pi4-2021](https://github.com/pimoroni/hyperpixel4/tree/square-pi4-2021)  - Pi 4 & Pi 400, HyperPixel4 Square (for boards manufactured 2021 and later)

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

## Totally Manual Rotation

:warning: for Xorg-based operating systems running on Pi 4 and Pi 400
:warning: must have `dtoverlay=vc4-fkms-v3d` in `/boot/config.txt`

### Rotation on the fly

You can use xrandr and xinput to rotate the display and touchscreen in turn.

For HyperPixel Square, substitute the device name with "pointer:generic ft5x06 (11)".

#### Left

```
DISPLAY=:0.0 xrandr --output DSI-1 --rotate left
DISPLAY=:0.0 xinput set-prop "pointer:Goodix Capacitive TouchScreen" "libinput Calibration Matrix" 0 -1 1 1 0 0 0 0 1
```

#### Right

```
DISPLAY=:0.0 xrandr --output DSI-1 --rotate right
DISPLAY=:0.0 xinput set-prop "pointer:Goodix Capacitive TouchScreen" "libinput Calibration Matrix" 0 1 0 -1 0 1 0 0 1
```

#### Normal

```
DISPLAY=:0.0 xrandr --output DSI-1 --rotate normal
DISPLAY=:0.0 xinput set-prop "pointer:Goodix Capacitive TouchScreen" "libinput Calibration Matrix" 1 0 0 0 1 0 0 0 1
```

#### Inverted

```
DISPLAY=:0.0 xrandr --output DSI-1 --rotate inverted
DISPLAY=:0.0 xinput set-prop "pointer:Goodix Capacitive TouchScreen" "libinput Calibration Matrix" -1 0 1 0 -1 1 0 0 1
```

### Persisting Rotation

Add the relevant settings from above into `/usr/share/X11/xorg.conf.d/88-hyperpixel4.conf`.

You will need the device name:

* "Goodix Capacitive TouchScreen" for HyperPixel 4 Rectangular
* "generic ft5x06 (11)" for HyperPixel 4 Square

And the 9 numbers from the "Calibration Matrix", eg: `-1 0 1 0 -1 1 0 0 1`

Plus the rotation direction for the monitor.

```
Section "InputClass"
	Identifier "libinput HyperPixel4 Rectangular"
	MatchProduct "Goodix Capacitive TouchScreen"
	Option "CalibrationMatrix" "0 -1 1 1 0 0 0 0 1"
EndSection

Section "Monitor"
	Identifier "DSI-1"
	Option "Rotate" "left"
EndSection
```

If you're using lightdm (the default window manager on Raspberry Pi OS) and it's calling `/usr/share/dispsetup.sh` you'll need to either disable that call in `/etc/lightdm/lightdm.conf` or change `dispsetup.sh` to just `exit 0`. Removing `dispsetup.sh` will break lightdm and boot you to a black screen of death.

* :warning: Running "Screen Configuration" will re-create `dispsetup.sh` and override your Xorg settings
* :warning: Removing `dispsetup.sh` from `/etc/lightdm/lightdm.conf` will prevent "Screen Configuration" settings for persisting.
* You should probably use `hyperpixel4-rotate` unless you really know what you're doing!

## Troubleshooting

Where possible we are collecting known FAQs under the `notice` label in our issue tracker.

[`Notice` Issue Tracker](https://github.com/pimoroni/hyperpixel4/issues?q=is%3Aissue+label%3Anotice+)

If your issue is not covered by one of these provided by our team and community 
then we ask you to provide some debugging information using the following oneliner:

```bash
curl -sSL https://raw.githubusercontent.com/pimoroni/hyperpixel4/master/hyperpixel4-debug.sh | bash
```

Then [file a bug report](https://github.com/pimoroni/hyperpixel4/issues/new/choose).


