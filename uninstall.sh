#!/bin/bash

SERVICE_NAME="hyperpixel4-init.service"
SERVICE_PATH="/etc/systemd/system"
BINARY_NAME="hyperpixel4-init"
BINARY_PATH="/usr/bin"
OVERLAY_PATH="/boot/overlays"
OVERLAY_NAME="hyperpixel4.dtbo"
OVERLAY_CONFIG="dtoverlay=hyperpixel4"

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
	printf "Script must be run as root. Try 'sudo ./uninstall.sh'\n"
	exit 1
fi

if [ -f "$SERVICE_PATH/$SERVICE_NAME" ]; then
	systemctl stop $SERVICE_NAME
	systemctl disable $SERVICE_NAME
	rm -f "$SERVICE_PATH/$SERVICE_NAME"
	systemctl daemon-reload
	printf "Removed: $SERVICE_PATH/$SERVICE_NAME\n"
else
	printf "Skipped: $SERVICE_PATH/$SERVICE_NAME, not installed\n"
fi

if [ -f "$BINARY_PATH/$BINARY_NAME" ]; then
	rm -f "$BINARY_PATH/$BINARY_NAME"
	printf "Removed: $BINARY_PATH/$BINARY_NAME\n"
else
	printf "Skipped $BINARY_PATH/$BINARY_NAME, not installed\n"
fi

if [ -f "$OVERLAY_PATH/$OVERLAY_NAME" ]; then
	rm -f "$OVERLAY_PATH/$OVERLAY_NAME"
	printf "Removed: $OVERLAY_PATH/$OVERLAY_NAME\n"
else
	printf "Skipped: $OVERLAY_PATH/$OVERLAY_NAME, not installed\n"
fi

if [ -f "$CONFIG" ]; then
	for ((i = 0; i < ${#CONFIG_LINES[@]}; i++)); do
		CONFIG_LINE="${CONFIG_LINES[$i]}"

		grep -e "^$CONFIG_LINE" $CONFIG > /dev/null
		STATUS=$?
		if [ $STATUS -eq 0 ]; then
			sed -i "/^$CONFIG_LINE/d" $CONFIG
			printf "Removed: line $CONFIG_LINE from $CONFIG\n"
		else
			printf "Skipped: $CONFIG, line $CONFIG_LINE not found\n"
		fi
	done
fi
