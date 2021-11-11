#!/bin/bash

SERVICE_NAME="hyperpixel4-init.service"
SERVICE_PATH="/etc/systemd/system"
BINARY_NAME="hyperpixel4-init"
ROTATE_NAME="hyperpixel4-rotate"
BINARY_PATH="/usr/bin"
OVERLAY_PATH="/boot/overlays"
DEB_NAME="panel-pimoroni-hyperpixel4-dkms_1.0_armhf.deb"

CONFIG="/boot/config.txt"

CONFIG_LINES=(
	"dtoverlay=vc4-kms-dpi-hyperpixel4"
	"dtoverlay=hyperpixel4-touch"
)

if [ $(id -u) -ne 0 ]; then
		printf "Script must be run as root. Try 'sudo ./install.sh'\n"
		exit 1
fi

function apt_pkg_install {
	PACKAGES=()
	PACKAGES_IN=("$@")
	for ((i = 0; i < ${#PACKAGES_IN[@]}; i++)); do
		PACKAGE="${PACKAGES_IN[$i]}"
		if [ "$PACKAGE" == "" ]; then continue; fi
		printf "Checking for $PACKAGE\n"
		dpkg -L $PACKAGE > /dev/null 2>&1
		if [ "$?" == "1" ]; then
			PACKAGES+=("$PACKAGE")
		fi
	done
	PACKAGES="${PACKAGES[@]}"
	if ! [ "$PACKAGES" == "" ]; then
		echo "Installing missing packages: $PACKAGES"
		if [ ! $APT_HAS_UPDATED ]; then
			apt update
			APT_HAS_UPDATED=true
		fi
		apt install -y $PACKAGES
		if [ -f "$UNINSTALLER" ]; then
			echo "apt uninstall -y $PACKAGES"
		fi
	fi
}

function build_overlay {
if [ ! -f "dist/$1.dtbo" ]; then
	if [ ! -f "/usr/bin/dtc" ]; then
		printf "This script requires device-tree-compiler, please \"sudo apt install device-tree-compiler\"\n";
		exit 1
	fi
	printf "Notice: building $1.dtbo\n";
	dtc -@ -I dts -O dtb -o dist/$1.dtbo src/$1-overlay.dts # > /dev/null 2>&1
fi
}

printf "Installing dkms and kernel headers, hang in there! This may take a while!...\n"
DEPS=( "dkms" "raspberrypi-kernel-headers" )
apt_pkg_install "dkms" "raspberrypi-kernel-headers", "python3-rpi.gpio"

sudo dpkg -i dist/$DEB_NAME

build_overlay vc4-kms-dpi-hyperpixel4
build_overlay hyperpixel4-touch

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
	cp dist/hyperpixel4-touch.dtbo $OVERLAY_PATH
	cp dist/vc4-kms-dpi-hyperpixel4.dtbo $OVERLAY_PATH
	printf "Installed: $OVERLAY_PATH/hyperpixel4-touch.dtbo\n"
	printf "Installed: $OVERLAY_PATH/vc4-kms-dpi-hyperpixel4.dtbo\n"
else
	printf "Warning: unable to copy overlays to $OVERLAY_PATH\n"
fi

if [ -f "$CONFIG" ]; then
	NEWLINE=0
	for ((i = 0; i < ${#CONFIG_LINES[@]}; i++)); do
		CONFIG_LINE="${CONFIG_LINES[$i]}"
		grep -E "^(#|# )$CONFIG_LINE[$ #]" $CONFIG > /dev/null
		STATUS=$?
		if [ $STATUS -eq 1 ]; then
			grep -E "^$CONFIG_LINE([ #]|$)" $CONFIG > /dev/null
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
			sed -i -r -E "s/^(#|# )$CONFIG_LINE([# ]|$)/$CONFIG_LINE\2/" $CONFIG
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
