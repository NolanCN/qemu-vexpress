# ARM Embedded System Setup

This repository contains shell scripts for setting up an ARM-based embedded system using QEMU. The scripts include downloading, compiling, and configuring components such as U-Boot, the Linux kernel, and BusyBox, as well as running QEMU with the configured system.

## Experimental Environment

The scripts were tested and developed in the following environment:

- **Operating System:** Ubuntu 22.04.3 LTS
- **GNU Make:** 4.3
- **Git:** 2.34.1
- **arm-linux-gnueabi-gcc:** 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
- **arm-linux-gnueabi-g++:** 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
- **QEMU emulator:** 6.2.0 (Debian 1:6.2+dfsg-2ubuntu6.15)

## Scripts

1. **sudo_install_dependencies.sh**

    - Installs build dependencies required for compilation.
    - Must be run with root privileges.

    ```bash
    # Usage:
    sudo ./sudo_install_dependencies.sh
    ```

2. **install.sh**

    - Downloads, compiles, and configures U-Boot, the Linux kernel, and BusyBox.
    - Creates a minimal root filesystem for an ARM target.
    - Generates a log file (`log_file.txt`) to record the installation process.

    ```bash
    # Usage:
    sudo ./install.sh
    ```

3. **run_qemu.sh**

    - Runs QEMU to emulate the ARM system with the specified kernel and root filesystem.
    - Requires QEMU, an ARM kernel (zImage), and a root filesystem image (rootfs.img).
  
    ```bash
    # Usage:
    ./run_qemu.sh
    ```

## Prerequisites

- QEMU installed
- ARM kernel (zImage) and device tree blob (dtb) from Linux kernel compilation
- Root filesystem image (rootfs.img) generated using the install.sh script

## Notes

- The scripts were generated using the GPT-3 language model from OpenAI.
- Make sure to review and customize the scripts based on your specific requirements.

Feel free to explore and adapt these scripts for your ARM embedded system development. If you encounter any issues or have questions, don't hesitate to reach out!
