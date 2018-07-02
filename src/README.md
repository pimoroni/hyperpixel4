# HyperPixel 4.0" Drivers

## hyperpixel4-init.c

Source for the hyperpixel4-init binary.

It's designed to be statically linked against bcm2835 and runs all of the init routine required for HyperPixel 4.0"

## hyperpixel4.dts

Source for hyperpixel4.dtbo device-tree overlay.

This overlay sets up:

* GPIO backlight (on/off) functionality
* Goodix multitouch digitiser
