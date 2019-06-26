build:
	dtc -I dts -O dtb -o hyperpixel4.dtbo hyperpixel4.dts

install:
	cp hyperpixel4.dtbo /boot/overlays/

test:
	dtoverlay hyperpixel4.dtbo
