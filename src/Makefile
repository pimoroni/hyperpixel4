build:
	dtc -I dts -O dtb -Wno-unit_address_vs_reg -o hyperpixel4-touch.dtbo hyperpixel4-touch-overlay.dts
	dtc -I dts -O dtb -Wno-unit_address_vs_reg -o vc4-dpi-hyperpixel4.dtbo vc4-dpi-hyperpixel4-overlay.dts

install:
	cp hyperpixel4.dtbo /boot/overlays/

test:
	dtoverlay hyperpixel4.dtbo
