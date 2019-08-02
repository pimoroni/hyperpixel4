#!/bin/bash

SERVICE_PATH="/etc/systemd/system"
BINARY_PATH="/usr/bin"
ROTATE_NAME="hyperpixel4-rotate"
OVERLAY_PATH="/boot/overlays"
OVERLAY_NAME="hyperpixel4.dtbo"
OVERLAY_SRC="hyperpixel4.dts"
UDEV_RULES="98-hyperpixel4-square-calibration.rules"
UDEV_PATH="/etc/udev/rules.d"

CONFIG="/boot/config.txt"

CONFIG_LINES=(
	"dtoverlay=hyperpixel4"
	"enable_dpi_lcd=1"
	"dpi_group=2"
	"dpi_mode=87"
	"dpi_output_format=0x7f226"
	"dpi_timings=720 0 15 15 15 720 0 10 10 10 0 0 0 60 0 35113500 6"
)

if [ $(id -u) -ne 0 ]; then
		printf "Script must be run as root. Try 'sudo ./install.sh'\n"
		exit 1
fi

if [ ! -f "dist/$OVERLAY_NAME" ]; then
	if [ ! -f "/usr/bin/dtc" ]; then
		printf "This script requires device-tree-compiler, please \"sudo apt install device-tree-compiler\"\n";
		exit 1
	fi
	printf "Notice: building $OVERLAY_NAME\n";
	dtc -I dts -O dtb -o dist/$OVERLAY_NAME src/$OVERLAY_SRC > /dev/null 2>&1
fi

cp dist/$ROTATE_NAME $BINARY_PATH

if [ -d "$UDEV_PATH" ]; then
	cp dist/$UDEV_RULES $UDEV_PATH
	printf "Installed: $UDEV_PATH/$UDEV_RULES\n"
fi

if [ -d "$OVERLAY_PATH" ]; then
	cp dist/$OVERLAY_NAME $OVERLAY_PATH
	printf "Installed: $OVERLAY_PATH/$OVERLAY_NAME\n"
else
	printf "Warning: unable to copy $OVERLAY_NAME to $OVERLAY_PATH\n"
fi

if [ -f "$CONFIG" ]; then
	printf "Disabling i2c and SPI!\n"
	raspi-config nonint do_spi 1
	raspi-config nonint do_i2c 1
	NEWLINE=0
	for ((i = 0; i < ${#CONFIG_LINES[@]}; i++)); do
		CONFIG_LINE="${CONFIG_LINES[$i]}"
		grep -e "^#$CONFIG_LINE" $CONFIG > /dev/null
		STATUS=$?
		if [ $STATUS -eq 1 ]; then
			grep -e "^$CONFIG_LINE" $CONFIG > /dev/null
			STATUS=$?
			if [ $STATUS -eq 1 ]; then
				# Line is missing from config file
				if [ ! $NEWLINE -eq 1 ]; then
					# Add newline if this is the first new entry
					echo "" >> $CONFIG
					NEWLINE=1
				fi
				# Add the config line
				echo "$CONFIG_LINE" >> $CONFIG
				printf "Config: Added $CONFIG_LINE to $CONFIG\n"
			else
				printf "Skipped: $CONFIG_LINE already exists in $CONFIG\n"
			fi
		else
			sed $CONFIG -i -e "s/^#$CONFIG_LINE/$CONFIG_LINE/"
			printf "Config: Uncommented $CONFIG_LINE in $CONFIG\n"
		fi
	done
else
	printf "Warning: unable to find $CONFIG, is /boot not mounted?\n"
	printf "Please add $OVERLAY_CONFIG to your config.txt\n"
	printf "Make sure you also disable i2c and SPI\n"
fi

printf "\nAll done!\n*** Make sure you stop and disable any running services or scripts which use GPIO! ***\n\n"


