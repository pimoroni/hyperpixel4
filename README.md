# HyperPixel 4.0" Drivers

HyperPixel 4.0 is an 800x480 pixel display for the Raspberr Pi, with optional capacitive touchscreen.

## Installing / Uninstalling

First, clone this GitHub repository to your Pi:

```
git clone https://github.com/pimoroni/hyperpixel4
```

Then run the installer to install:

```
cd hyperpixel4
sudo ./install.sh
```

## 180 Degree Rotation

Note: You *must* build the latest dtoverlay file to enable rotation support:

1. Go into `src`
2. run `make` to build a new hyperpixel4.dtbo with rotation support
3. copy the overlay with `sudo cp hyperpixel4.dtbo /boot/overlays/`

To rotate your HyperPixel4 you must edit /boot/config.txt and change the following lines:

1. Change `dtoverlay=hyperpixel4` to `dtoverlay=hyperpixel4:rotate`
2. Change `display_rotate=3` to `display_rotate=1`

This will rotate both the display and the touchscreen input to match.

If you're using a non-touchscreen HyperPixel4 you need only change `display_rotate`.
