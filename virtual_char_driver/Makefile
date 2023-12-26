obj-m += virtual_char_device.o

# Specify the cross-compiler and its path
CROSS_COMPILE = /usr/bin/arm-linux-gnueabi-
# Specify the kernel source path
KERNEL_SRC = ../linux-6.1.68

all:
	make ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNEL_SRC) M=$(PWD) modules

clean:
	make -C $(KERNEL_SRC) M=$(PWD) clean
