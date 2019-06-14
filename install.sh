#!/bin/bash

SERVICE_NAME="hyperpixel4-init.service"
SERVICE_PATH="/etc/systemd/system"
BINARY_NAME="hyperpixel4-init"
BINARY_PATH="/usr/bin"
OVERLAY_PATH="/boot/overlays"
OVERLAY_NAME="hyperpixel4.dtbo"
OVERLAY_SRC="hyperpixel4.dts"
UDEV_RULES="98-hyperpixel4-calibration.rules"
UDEV_PATH="/etc/udev/rules.d"

CONFIG="/boot/config.txt"

CONFIG_LINES=(
	"dtoverlay=hyperpixel4"
	"overscan_left=0"
	"overscan_right=0"
	"overscan_top=0"
	"overscan_bottom=0"
	"framebuffer_width=800"
	"framebuffer_height=480"
	"enable_dpi_lcd=1"
	"display_default_lcd=1"
	"dpi_group=2"
	"dpi_mode=87"
	"dpi_output_format=0x7f216"
	"display_rotate=3"
	"hdmi_timings=480 0 10 16 59 800 0 15 113 15 0 0 0 60 0 32000000 6"
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

if [ -d "$UDEV_PATH" ]; then
	cp dist/$UDEV_RULES $UDEV_PATH
	printf "Installed: $UDEV_PATH/$UDEV_RULES\n"
fi

if [ -d "$SERVICE_PATH" ]; then
	cp dist/$BINARY_NAME $BINARY_PATH
	cp dist/$SERVICE_NAME $SERVICE_PATH
	systemctl daemon-reload
	systemctl enable $SERVICE_NAME
	systemctl start $SERVICE_NAME
	printf "Installed: $BINARY_PATH/$BINARY_NAME\n"
	printf "Installed: $SERVICE_PATH/$SERVICE_NAME\n"
else
	printf "Warning: cannot find $SERVICE_PATH for $SERVICE_NAME\n"
fi

if [ -d "$OVERLAY_PATH" ]; then
	cp dist/$OVERLAY_NAME $OVERLAY_PATH
	printf "Installed: $OVERLAY_PATH/$OVERLAY_NAME\n"
else
	printf "Warning: unable to copy $OVERLAY_NAME to $OVERLAY_PATH\n"
fi

if [ -f "$CONFIG" ]; then
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
fi


