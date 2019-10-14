# HyperPixel 4.0" Drivers

HyperPixel 4.0 is an 800x480 pixel display for the Raspberry Pi, with optional capacitive touchscreen.

## Installing / Uninstalling

1. Make sure you're running Raspbian Buster or Raspbian Stretch.

2. Update your Pi with `sudo apt update` and `sudo apt upgrade`.

3. Clone this GitHub repository to your Pi:

```
git clone https://github.com/pimoroni/hyperpixel4 -b pi3
```

4. Then run the installer to install:

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

This command changes the `display_rotate` parameter in `/boot/config.txt` and changes the touchscreen calibration dropped into `/etc/udev/rules.d/`.

## Touch rotation

If you're having trouble with your touch being 180 degrees rotated to your screen, or need to rotate the touch for other reasons you can use some additional arguments for the dtoverlay in config.txt, these are:

* `touchscreen-inverted-x`
* `touchscreen-inverted-y`
* `touchscreen-swapped-x-y`

For example, to rotate touch 180 degrees you want to invert both the x and y axis, by changing the `dtoverlay=hyperpixel4` line in your `/boot/config.txt` to:

```
dtoverlay=hyperpixel4,touchscreen-inverted-x,touchscreen-inverted-y
```

