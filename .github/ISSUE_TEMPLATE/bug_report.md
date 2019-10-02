---
name: Bug report
about: Report a bug with HyperPixel 4.0 Rectangular or Square
title: ''
labels: ''
assignees: ''

---

**Describe the bug**

What's gone wrong?

**To Reproduce**

What install steps did you go through so far? Did you install from GitHub or use our one-line-installer?

**Your HyperPixel 4**

Let us know which HyperPixel 4 board you're using. Note: if you're having a problem with the original HyperPixel you should go to: https://github.com/pimoroni/hyperpixel

1. Is it Square or Rectangular?
2. Touch or non Touch?
3. Approximately when was it purchased
4. How is it connected to your Pi

**Your Raspberry Pi**

Give as much detail about your Pi and OS as possible. We only officially support Raspbian, but might be able to point you in the right direction if the problem is with another OS.

1. What model of Raspberry Pi are you using (the result of `cat /proc/cpuinfo | grep Revision` can tell us this exactly
2. Which OS release are you using: `lsb_release --description` and `uname -r`
3. Is this a fresh OS setup, or one you might have previously installed scripts/add-ons on?

**Extra debugging information**

If you're having a problem with touch, try checking `dmesg` for related errors:

`dmesg | grep Goodix` for HyperPixel 4.0" Rectangular
`dmesg | grep ft5` for HyperPixel 4.0" Square

And check i2c is working:

`ls /dev/i2c-`

And your HyperPixel 4 touch is showing up (there should be an address blocked out with UU in the below command):

`sudo i2cdetect -y X` ( where X is the number of i2c bus found in the command above)
