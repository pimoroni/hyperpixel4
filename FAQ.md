# HyperPixel 4 FAQ

**This repository is archived and no longer maintained.** HyperPixel 4 is now supported by
drivers that ship as part of Raspberry Pi OS so - for almost everyone - there is nothing here
left to install. This document collects the answers that came up most often across seven
years of issues, so they stay findable after the issue tracker closes.

- **Hardware fault, damaged board, or you think your display is defective:** contact
  [support@pimoroni.com](mailto:support@pimoroni.com).
- **Questions, projects and troubleshooting:** [forums.pimoroni.com](https://forums.pimoroni.com).
- **Pinout:** [pinout.xyz/pinout/hyperpixel4](https://pinout.xyz/pinout/hyperpixel4).

---

## Contents

1. [Start here: the supported setup](#1-start-here-the-supported-setup)
2. [Which board do I have?](#2-which-board-do-i-have)
3. [Rotation](#3-rotation)
4. [I get a backlight but no picture](#4-i-get-a-backlight-but-no-picture)
5. [GPIO, I2C, SPI and cameras](#5-gpio-i2c-spi-and-cameras)
6. [Backlight, brightness and blanking](#6-backlight-brightness-and-blanking)
7. [Display quality problems](#7-display-quality-problems)
8. [Other operating systems and other boards](#8-other-operating-systems-and-other-boards)
9. [The legacy installer](#9-the-legacy-installer)

---

## 1. Start here: the supported setup

On Raspberry Pi OS images dated **2022-04-04 or later** (Bullseye, Bookworm, Trixie) the
drivers are already in the OS. **Do not run our installer.** Add one line to your boot
config:

| Board | Line |
|---|---|
| HyperPixel 4 Rectangular | `dtoverlay=vc4-kms-dpi-hyperpixel4` |
| HyperPixel 4 Square (2021 and later, "XP") | `dtoverlay=vc4-kms-dpi-hyperpixel4sq` |

Three things people get wrong:

**The config file moved.** It is `/boot/firmware/config.txt` on Bookworm and later, and
`/boot/config.txt` on Bullseye and earlier. Older guides and forum posts all say the latter.

**You must disable I2C, SPI and any other interfaces** in `raspi-config`. HyperPixel drives
a DPI display over nearly every GPIO pin. Enabling I2C tells the Pi to use the display's
vsync and hsync pins as an I2C bus; it cannot do both, and device-tree resolves the conflict
by giving you a black screen. This is the single most common cause of "backlight but no
picture".

**Leave `dtoverlay=vc4-kms-v3d` alone.** The HyperPixel overlay requires it. Removing or
commenting it out — advice that circulated widely during the Bullseye transition — breaks
the display on current images.

### Coming from the old installer?

A fresh image is strongly recommended. If you can't, you must remove every trace of the
legacy setup, or the two will fight:

```bash
sudo systemctl disable hyperpixel4-init.service
```

Then delete these from your config file if present: `dtoverlay=hyperpixel4` (and any
`hyperpixel4-*` variants), `enable_dpi_lcd`, `display_default_lcd`, `dpi_group`, `dpi_mode`,
`dpi_output_format`, `dpi_timings`, `display_rotate`, `display_lcd_rotate`, and
`gpio=0-25=a2`.

A half-removed legacy install is the second most common cause of a blank or garbled screen.

---

## 2. Which board do I have?

This matters more than anything else in this document, because **the two Square variants are
not interchangeable**.

| Board | In-kernel driver? | Notes |
|---|---|---|
| Rectangular, 800x480 | Yes | Goodix touch controller |
| Square 2021 and later, marked **HyperPixel XP**, 720x720 | Yes | FT5x06 touch controller |
| Square 2020 and earlier, 720x720 | **No** | Different timings and needs an SPI init sequence. Will never work with `vc4-kms-dpi-hyperpixel4sq` |

If you have a pre-2021 Square and you add the `sq` overlay, you will get **vertical stripes
or a scrolling, garbled image** — because the panel is being driven with the wrong timings
and was never initialised. This is not a fault. Your options are the
[legacy installer](#9-the-legacy-installer) on an older OS, or replacing the board.

Not sure? Check the silkscreen on the back of the board for the "XP" marking.

---

## 3. Rotation

HyperPixel 4 is natively a **portrait** panel (480x800 for Rectangular, 720x720 for Square).
Rotation is the single largest topic in this repo's history, and the answer depends on
whether you're running a desktop.

### The easy way (Raspberry Pi OS with desktop)

Open **Preferences > Screen Configuration**, **right-click** the box labelled `DPI-1`, and
pick an orientation. On Bookworm and later the same utility can associate a touchscreen with
a display, which handles touch rotation too.

`left` gives you headers at the top; `right` gives you headers at the bottom.

Do not also set `rotate=` in your config file — pick one method or they will conflict.

### In config.txt (works without a desktop)

For **Rectangular**, add a `dtparam` line immediately under the `dtoverlay` line:

| Orientation | Line |
|---|---|
| Portrait, header on the right | *(default, no line needed)* |
| Landscape, header on the bottom | `dtparam=rotate=90,touchscreen-swapped-x-y,touchscreen-inverted-y` |
| Portrait, header on the left | `dtparam=rotate=180` |
| Landscape, header on the top | `dtparam=rotate=270,touchscreen-swapped-x-y,touchscreen-inverted-x` |

For **Square**, `rotate=` works but the touch parameters do not — `touchscreen-swapped-x-y`
is ignored. Rotate the display in config.txt and correct touch separately, below.

### Rotating the console

```
video=DSI-1:480x800 fbcon=rotate:1
```

in `cmdline.txt`, on the single existing line. Use `fbcon=rotate:3` for the opposite
landscape orientation.

> **Connector name gotcha:** the DPI connector is called `DSI-1` on older kernels and
> `DPI-1` on newer ones. If a rotation command silently does nothing, check which one your
> system uses with `xrandr` (X11) or `ls /sys/class/drm/`.

### Correcting touch when the display rotates but touch doesn't

Under **Wayland / labwc** (the Bookworm and later default), a udev rule is the reliable
method. Create `/etc/udev/rules.d/98-hyperpixel4-calibration.rules` with **one** of:

```
# left
ATTRS{name}=="*Goodix Capacitive TouchScreen", ENV{LIBINPUT_CALIBRATION_MATRIX}="0 -1 1 1 0 0 0 0 1"
# right
ATTRS{name}=="*Goodix Capacitive TouchScreen", ENV{LIBINPUT_CALIBRATION_MATRIX}="0 1 0 -1 0 1 0 0 1"
# inverted
ATTRS{name}=="*Goodix Capacitive TouchScreen", ENV{LIBINPUT_CALIBRATION_MATRIX}="-1 0 1 0 -1 1 0 0 1"
# normal
ATTRS{name}=="*Goodix Capacitive TouchScreen", ENV{LIBINPUT_CALIBRATION_MATRIX}="1 0 0 0 1 0 0 0 1"
```

For Square, match on `*generic ft5x06*` instead. Confirm your device's exact name with
`libinput list-devices` or `cat /proc/bus/input/devices`.

Under **X11**, put the same matrix in `/usr/share/X11/xorg.conf.d/88-hyperpixel4.conf`:

```
Section "InputClass"
    Identifier "libinput HyperPixel4"
    MatchProduct "Goodix Capacitive TouchScreen"
    Option "CalibrationMatrix" "0 -1 1 1 0 0 0 0 1"
EndSection
```

> Beware: running "Screen Configuration" regenerates `/usr/share/dispsetup.sh` and will
> override Xorg settings. Do not delete `dispsetup.sh` outright — that breaks lightdm and
> boots you to a black screen.

### Can I make it a native 800x480 landscape display?

**No.** The panel is physically portrait and reports itself as such. There is no way to make
it present an 800x480 framebuffer. Anything that draws directly to the framebuffer rather
than through a compositor — RetroPie, SDL, pygame, OpenCV, Kivy, KlipperScreen — will see a
portrait surface and must handle rotation itself. Desktop rotation works because X11 or
Wayland rotates it for you.

---

## 4. I get a backlight but no picture

Work through these in order. Between them they account for the overwhelming majority of
reports:

1. **I2C and SPI are still enabled.** Turn both off in `raspi-config` and reboot. See
   [section 1](#1-start-here-the-supported-setup).
2. **Remnants of the legacy installer.** Disable `hyperpixel4-init.service` and strip the
   old config lines, or start from a fresh image.
3. **You edited the wrong file.** `/boot/firmware/config.txt` on Bookworm and later.
4. **You removed `dtoverlay=vc4-kms-v3d`.** Put it back.
5. **You have a pre-2021 Square with the `sq` overlay.** See
   [section 2](#2-which-board-do-i-have).
6. **An HDMI display is connected.** Disconnect it and reboot — with a monitor attached the
   HyperPixel can end up as a secondary display, and in some configurations that has also
   caused touch coordinates to be scaled against the HDMI resolution instead.
7. **Reboot again.** Several people, including us, have seen the display come up only on the
   second or third boot after a config change.
8. **Reseat the display.** Check the header is fully seated — standoffs can hold the board
   just off the pins. If you're using a riser or a Cyberdeck-style HAT, check that too.

If none of that helps, the board may genuinely be faulty; several people who reached this
point had defective units replaced by their retailer. Email
[support@pimoroni.com](mailto:support@pimoroni.com).

You can still collect debug information with:

```bash
curl -sSL https://raw.githubusercontent.com/pimoroni/hyperpixel4/master/hyperpixel4-debug.sh | bash
```

---

## 5. GPIO, I2C, SPI and cameras

**Can I use other GPIO pins?** Essentially no. DPI needs almost all of them. Specifically
BCM18, BCM26 and BCM27 carry the SPI signals that initialise the display, BCM19 controls the
backlight, and BCM10/BCM11 are the touch I2C bus. The full map is on
[pinout.xyz](https://pinout.xyz/pinout/hyperpixel4).

**Can I re-enable I2C or SPI for another device?** Not the standard ones — those pins are the
display's. But HyperPixel provides its own I2C bus on the touch pins, and you can hang other
devices off it. It appears as a high-numbered bus whose number varies by OS and Pi model
(`i2c-3`, `i2c-11`, `i2c-20` and `i2c-22` have all been seen). Find yours:

```bash
ls /dev/i2c-*
i2cdetect -y 22   # substitute your number
```

If a library insists on bus 1, symlink it:

```bash
sudo ln -s /dev/i2c-22 /dev/i2c-1
```

You may need `sudo modprobe i2c-dev` for the device node to appear. If you need general
purpose GPIO, put an I2C expander such as an MCP23017 on this bus.

**Camera?** The CSI camera connector is a separate interface and should work. Rotation
interactions between a camera preview and a rotated desktop are an OS-level problem we can't
fix from here.

**A DSI display at the same time?** No. DPI and DSI share a pixel valve on the Pi and are
mutually exclusive. DPI plus HDMI does work.

**Powering the Pi through the header?** Both 5V pins are tied together on the board, so use
either. All ground pins are connected. Physical pins 4 and 6 are a convenient adjacent pair.

---

## 6. Backlight, brightness and blanking

**Can I dim the backlight?** No — it's on or off. There is no PWM backlight support:
`pwm-backlight` isn't shipped in Raspberry Pi OS, and the device-tree work to enable it
never landed ([raspberrypi/linux#2063](https://github.com/raspberrypi/linux/issues/2063), open
since 2017). `/sys/class/backlight/*/brightness` accepts only 0 and 1, which is why software
brightness sliders appear to switch the screen off partway down.

**The backlight stays on after shutdown.** Add to your config file:

```
dtoverlay=gpio-poweroff,gpiopin=19,active_low=1
```

**Image retention / ghosting.** The panel isn't put to sleep when nothing is being drawn, and
leaving a static image up for long periods can leave a visible ghost. It normally clears
after a full power cycle. Configure screen blanking or shut the Pi down when idle.

---

## 7. Display quality problems

**Vertical stripes, scrolling or garbled image, Square only.** You have a pre-2021 Square
being driven with the wrong timings. See [section 2](#2-which-board-do-i-have).

**Wildly wrong or inverted colours.** Remove `gpio=0-25=a2` from your config file — a
leftover from very old legacy setups.

**Faint flickering or moving lines, most visible on dark greys.** Several people have
reported this across multiple boards, and it reproduces on both the legacy and the in-kernel
drivers, which points at the panel or the DPI signalling rather than software. We were never
able to reproduce it reliably or root-cause it. If it's bad enough to bother you, contact
support — it may be treated as a hardware fault.

**A flickering white line along one edge, Square only.** Also never reproduced in-house;
believed to sit in the Pi's display stack rather than in HyperPixel. Rotating the display
tells you which: if the line moves with the image it's software, if it stays put it's the
panel.

**Screen only works after the second or third boot.** Known, long-standing, and never
pinned down. If it's persistent, a fresh image tends to clear it.

---

## 8. Other operating systems and other boards

Only **Raspberry Pi OS** was ever tested. Everything else is best-effort.

Distributions that ship Raspberry Pi's own firmware and overlays — Ubuntu for Pi, RetroPie,
Batocera, OctoPi, Volumio and similar — can usually be made to work with the same
`dtoverlay` line, provided their kernel is new enough to contain the panel driver and you
disable the conflicting interfaces. Distributions with their own kernels (Arch ARM, FreeBSD,
Android) may not include the panel driver at all, in which case there's nothing to enable.

**Non-Raspberry-Pi single board computers** — Jetson, Rock64, Pine64 and the rest — will not
work. A 40-pin header that is physically Pi-compatible is not enough; HyperPixel needs a DPI
peripheral with the same pin mapping, which these boards do not have.

---

## 9. The legacy installer

Still available, for pre-2021 Square boards and for anyone tied to an old OS:

```bash
curl -sSL https://get.pimoroni.com/hyperpixel4-legacy | bash
```

It asks whether your board is "Rectangular" or "Weirdly Square", whether you're on a Pi 4/400
or a Pi 3B+ or earlier, and — for Square — roughly when you bought it. It then checks out the
matching branch from this repository.

The branches remain readable in the archive:

| Branch | Board and Pi |
|---|---|
| `pi3` | Rectangular, Pi 3B+ and earlier |
| `pi4` | Rectangular, Pi 4 / Pi 400 |
| `square` | Square 2020 and earlier, Pi 3B+ and earlier |
| `square-pi4` | Square 2020 and earlier, Pi 4 / Pi 400 |
| `square-2021` | Square 2021 and later, Pi 3B+ and earlier |
| `square-pi4-2021` | Square 2021 and later, Pi 4 / Pi 400 |

The legacy drivers were built around the pre-KMS way of configuring DPI in `config.txt`. They
do not work on current Raspberry Pi OS and they will not be updated. The `hyperpixel4-rotate`
command belongs to this legacy setup only; on a current OS use the methods in
[section 3](#3-rotation) instead.

---

*Archived 2026. If something here is wrong or has stopped working, please post on
[forums.pimoroni.com](https://forums.pimoroni.com) so the community can correct it.*
