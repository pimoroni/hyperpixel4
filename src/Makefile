build:
	dtc -I dts -O dtb -Wno-unit_address_vs_reg -o hyperpixel4-common.dtbo hyperpixel4-common-overlay.dts
	dtc -I dts -O dtb -Wno-unit_address_vs_reg -o hyperpixel4-0x14.dtbo hyperpixel4-0x14-overlay.dts
	dtc -I dts -O dtb -Wno-unit_address_vs_reg -o hyperpixel4-0x5d.dtbo hyperpixel4-0x5d-overlay.dts

install:
	cp hyperpixel4-*.dtbo /boot/overlays/

test:
	dtoverlay hyperpixel4-common.dtbo
	dtoverlay hyperpixel4-0x14.dtbo
	dtoverlay hyperpixel4-0x5d.dtbo
