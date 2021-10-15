# HyperPixel 4.0" Drivers for Raspberry Pi 4

HyperPixel 4.0 is an 800x480 pixel display for the Raspberry Pi, with optional capacitive touchscreen.

These drivers are for the Raspberry Pi 4 specifically, and include new tools to take advantage of the "Screen Configuration" (xrandr) support that Pi 4's 3D accelerated desktop enables.

## Installing / Uninstalling

First, clone this GitHub repository branch to your Pi:

```
git clone https://github.com/pimoroni/hyperpixel4 -b pi4
```

Then run the installer to install:

```
cd hyperpixel4
sudo ./install.sh
```

## Rotation

To keep your touchscreen rotated with the display, you should rotate HyperPixel4 using the `hyperpixel4-rotate` command rather than "Screen Configuration."

This command will update your touch settings and screen configuration settings to match, and you can rotate between four modes: left, right, normal, inverted.

* left - landscape, power/HDMI on bottom
* right - landscape, power/HDMI on top
* normal - portrait, USB ports on top
* inverted - portrait, USB ports on bottom

If you want to change the position of your HyperPixel4 in a multi-display setup, you can use "Screen Configuration" as normal.

## Touch rotation

If you're having trouble with your touch being 180 degrees rotated to your screen, or need to rotate the touch for other reasons you can use some additional arguments for the dtoverlay in config.txt, these are:

* `touchscreen-inverted-x=1`
* `touchscreen-inverted-y=1`
* `touchscreen-swapped-x-y=1`

For example, to rotate touch 180 degrees you want to invert both the x and y axis, by changing the `dtoverlay=hyperpixel4` line in your `/boot/config.txt` to:

```
dtoverlay=hyperpixel4,touchscreen-inverted-x=1,touchscreen-inverted-y=1
```

:warning: Beware that config.txt has an 80 line length limit!

You can use `dtparam` to overcome this:

```
dtoverlay=hyperpixel4
dtparam=touchscreen-inverted-x=1
dtparam=touchscreen-inverted-y=1
dtparam=swapped-x-y=1
```
