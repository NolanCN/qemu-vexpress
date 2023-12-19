#!/bin/bash
#
# Name:   run.sh
# Author: yushu
# Brief:  Run QEMU with the ARM kernel and root filesystem
# Date:   2023-12-19
#


qemu-system-arm \
    -M vexpress-a9 \
    -m 512M \
    -kernel ./linux-6.1.68/arch/arm/boot/zImage \
    -dtb ./linux-6.1.68/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
    -append "root=/dev/mmcblk0 rw console=ttyAMA0" \
    --nographic \
    -sd rootfs.img

# QEMU Command Options:

# -M vexpress-a9:
#   Specifies the emulated machine type as vexpress-a9.

# -m 512M:
#   Sets the amount of RAM allocated to the emulated system to 512MB.

# -kernel ./linux-6.1.68/arch/arm/boot/zImage:
#   Specifies the path to the ARM kernel image (zImage).

# -dtb ./linux-6.1.68/arch/arm/boot/dts/vexpress-v2p-ca9.dtb:
#   Specifies the path to the device tree blob (dtb) for the emulated machine.

# -append "root=/dev/mmcblk0 rw console=ttyAMA0":
#   Appends kernel command-line parameters, including root filesystem location
#   and console settings.

# --nographic:
#   Disables graphical output and redirects the console to the terminal.

# -sd rootfs.img:
#   Specifies the root filesystem image to be used by the emulated system.
