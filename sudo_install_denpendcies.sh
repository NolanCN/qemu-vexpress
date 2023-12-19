#!/bin/bash
# 
# Name：  sudo_install_denpendcies.sh
# Author: yushu
# Brief:  Install build denpendcies; requires root priviledge
# Date:   2023-12-19
# 


# Define the list of packages to install
packages=("build-essential" "qemu-system" "gcc-arm-linux-gnueabi" "g++-arm-linux-gnueabi" "libncurses-dev" "libgmp3-dev" "libmpc-dev")

# Check if the script is executed with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Install the dependencies required for building
apt install -y "${packages[@]}"

