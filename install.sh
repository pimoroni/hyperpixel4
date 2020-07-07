#!/bin/bash

SERVICE_NAME="hyperpixel4-init.service"
SERVICE_PATH="/etc/systemd/system"
BINARY_NAME="hyperpixel4-init"
ROTATE_NAME="hyperpixel4-rotate"
BINARY_PATH="/usr/bin"
OVERLAY_PATH="/boot/overlays"

CONFIG="/boot/config.txt"

CONFIG_LINES=(
	"dtoverlay=hyperpixel4-common"
	"dtoverlay=hyperpixel4-0x14"
	"dtoverlay=hyperpixel4-0x5d"
	"gpio=0-25=a2"
	"enable_dpi_lcd=1"
	"dpi_group=2"
	"dpi_mode=87"
	"dpi_output_format=0x7f216"
	"dpi_timings=480 0 10 16 59 800 0 15 113 15 0 0 0 60 0 32000000 6"
)

if [ $(id -u) -ne 0 ]; then
		printf "Script must be run as root. Try 'sudo ./install.sh'\n"
		exit 1
fi

function build_overlay {
if [ ! -f "dist/$1.dtbo" ]; then
	if [ ! -f "/usr/bin/dtc" ]; then
		printf "This script requires device-tree-compiler, please \"sudo apt install device-tree-compiler\"\n";
		exit 1
	fi
	printf "Notice: building $1.dtbo\n";
	dtc -I dts -O dtb -o dist/$1.dtbo src/$1-overlay.dts > /dev/null 2>&1
fi
}

build_overlay hyperpixel4-common
build_overlay hyperpixel4-0x14
build_overlay hyperpixel4-0x5d

cp dist/$ROTATE_NAME $BINARY_PATH

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
	cp dist/hyperpixel4-common.dtbo $OVERLAY_PATH
	printf "Installed: $OVERLAY_PATH/hyperpixel4-common.dtbo\n"
	cp dist/hyperpixel4-0x14.dtbo $OVERLAY_PATH
	printf "Installed: $OVERLAY_PATH/hyperpixel4-0x14.dtbo\n"
	cp dist/hyperpixel4-0x5d.dtbo $OVERLAY_PATH	
	printf "Installed: $OVERLAY_PATH/hyperpixel4-0x5d.dtbo\n"
else
	printf "Warning: unable to copy overlays to $OVERLAY_PATH\n"
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

printf "\nAfter rebooting, use 'hyperpixel4-rotate left/right/normal/inverted' to rotate your display!\n\n"
printf "  left - Landscape, power/HDMI on bottom\n"
printf "  right - Landscape, power/HDMI on top\n"
printf "  normal - Portrait, USB ports on top\n"
printf "  inverted - Portrait, USB ports on bottom\n\n"
