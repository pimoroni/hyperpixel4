#! /bin/bash

function title(){
  echo ""
  echo "## $1"
  echo ""
}

title "Platform Information"
cat /proc/cpuinfo | grep Revision
lsb_release --description
uname -r

title "Touchscreen logs"
echo "Rectangular: Goodix"
dmesg | grep Goodix
echo "Square: ft5"
dmesg | grep ft5

title "I2C Devices and Mappings"
for x in "$(ls /dev/i2c-*)"
do
  echo "$x"
  i2cdetect -y "${x:9:1}"
done

title "Boot Config"
cat /boot/config.txt
