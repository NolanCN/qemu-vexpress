#!/bin/bash
#
# Name:   install.sh
# Author: yushu
# Brief:  downloading, compiling, and configuring several components 
#         to create a minimal root filesystem for an ARM target
# Date:   2023-12-19
#


export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-
# export http_proxy=http://172.24.1.1:7890/
# export https_proxy=http://172.24.1.1:7890/


# Log file path
log_file="./log_file.txt"
# URLs for software downloads
uboot_url="https://ftp.denx.de/pub/u-boot/u-boot-2023.10.tar.bz2"
linux_kernel_url="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.68.tar.xz"
busybox_url="https://www.busybox.net/downloads/busybox-1.36.1.tar.bz2"


# Function to log messages to the file with a timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$log_file"
}

# Function to log error messages and exit the script
log_error() {
    log "ERROR: $1"
    exit 1
}

# Enable strict mode for error handling
set -e

# echo "[软件环境]" > "$log_file"
# make --version >> "$log_file"
# echo "" >> "$log_file"
# git --version >> "$log_file"
# echo "" >> "$log_file"
# arm-linux-gnueabi-gcc --version >> "$log_file"
# arm-linux-gnueabi-g++ --version >> "$log_file"
# echo "" >> "$log_file"
# qemu-system-arm --version >> "$log_file"

# Log software environment information
log "[Software Environment]"
log "make version: $(make --version)"
log "git version: $(git --version)"
log "arm-linux-gnueabi-gcc version: $(arm-linux-gnueabi-gcc --version)"
log "arm-linux-gnueabi-g++ version: $(arm-linux-gnueabi-g++ --version)"
log "qemu-system-arm version: $(qemu-system-arm --version)"
log ""


# Download and compile U-Boot
if [ ! -f u-boot-2023.10.tar.bz2 ]; then
    echo "Downloading U-Boot..."
    curl -O "$uboot_url"
fi
if [ ! -d u-boot-2023.10 ]; then
    tar jxvf ./u-boot-2023.10.tar.bz2
    cd ./u-boot-2023.10
    cp Makefile Makefile.bak
    cd ..
fi
cd ./u-boot-2023.10
log "[编译u-boot]"
make vexpress_ca9x4_defconfig || log_error "Failed to configure U-Boot"
make -j8 || log_error "Failed to compile U-Boot"
cd ..


# Download and compile the Linux kernel
if [ ! -f linux-6.1.68.tar.xz ]; then
    echo "Downloading linux-6.1.68.tar.xz ..."
    curl -O "$linux_kernel_url"
fi
if [ ! -d linux-6.1.68  ]; then
    tar xf ./linux-6.1.68.tar.xz
    cd ./linux-6.1.68
    cp Makefile Makefile.bak
    cd ..
fi
cd ./linux-6.1.68
log "[编译linux-kernel]"
make vexpress_defconfig || log_error "Failed to configure Linux kernel"
make menuconfig
make -j8 || log_error "Failed to compile Linux kernel"
cd ..


# Download and compile BusyBox
if [ ! -f busybox-1.36.1.tar.bz2  ]; then
    echo "Downloading busybox-1.36.1.tar.bz2 ..."
    curl -O "$busybox_url"
fi
if [ ! -d busybox-1.36.1  ]; then
  tar jxvf ./busybox-1.36.1.tar.bz2
  cd busybox-1.36.1
  cp Makefile Makefile.bak
  cd ..
fi
cd ./busybox-1.36.1/
log "[编译BusyBox]"
make menuconfig
make || log_error "Failed to compile BusyBox"
make install
cd ..


rm -rf rootfs rootfs.img tmpfs
mkdir rootfs && cd rootfs
mkdir bin etc dev lib proc tmp root home sys usr sbin var mnt
cp -rfp /usr/arm-linux-gnueabi/lib/* lib
cp -rf ../busybox-1.36.1/examples/bootfloppy/etc/* etc
cp -rfd ../busybox-1.36.1/_install/* ./

mknod -m 666 dev/tty1    c 4 1
mknod -m 666 dev/tty2    c 4 2
mknod -m 666 dev/tty3    c 4 3
mknod -m 666 dev/tty4    c 4 4
mknod -m 666 dev/console c 5 1
mknod -m 666 dev/null    c 1 3

touch etc/mdev.conf
echo "controlC[0-9] 0:0 0660=snd/" >> etc/mdev.conf
echo "pcm.* 0:0 0660=snd/" >> etc/mdev.conf
echo "seq.* 0:0 0660=snd/" >> etc/mdev.conf
echo "mix.* 0:0 0660=snd/" >> etc/mdev.conf
echo "timer 0:0 0660=snd/" >> etc/mdev.conf

touch etc/init.d/rcS
echo "mount -n -t proc none /proc" >> etc/init.d/rcS
echo "mount -n -t sysfs none /sys" >> etc/init.d/rcS
echo "mdev -s" >> etc/init.d/rcS
cd ..


# Compile test application
log "Compiling the test application"
arm-linux-gnueabi-gcc test/hello.c -o rootfs/root/hello || log_error "Failed to compile the test application"

cd ./virtual_char_driver && make && cd ..
cp ./virtual_char_driver/virtual_char_device.ko ./rootfs/root


# Create root filesystem image
log "Creating root filesystem image"
dd if=/dev/zero of=rootfs.img bs=1M count=32
mkfs.ext3 rootfs.img
mkdir tmpfs
mount -t ext3 rootfs.img /mnt -o loop
cp -rf rootfs/* /mnt/
umount /mnt

# Disable strict mode at the end of the script
set +e
