#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

#define DEVICE_NAME "virtual_char_device"
#define BUFFER_SIZE 1024

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Yu Shu");
MODULE_DESCRIPTION("A simple virtual character device");
MODULE_VERSION("0.1");

static char device_buffer[BUFFER_SIZE];
static int major_number;
static int open_count = 0;

// Function prototypes
static int virtual_char_device_open(struct inode *inode, struct file *file);
static int virtual_char_device_release(struct inode *inode, struct file *file);
static ssize_t virtual_char_device_read(struct file *file, char __user *user_buffer, size_t count, loff_t *ppos);
static ssize_t virtual_char_device_write(struct file *file, const char __user *user_buffer, size_t count, loff_t *ppos);

// File operations structure
static struct file_operations virtual_char_device_fops = {
    .open = virtual_char_device_open,
    .release = virtual_char_device_release,
    .read = virtual_char_device_read,
    .write = virtual_char_device_write,
};

// Module initialization
static int __init virtual_char_device_init(void) {
    // Register the character device
    major_number = register_chrdev(0, DEVICE_NAME, &virtual_char_device_fops);
    if (major_number < 0) {
        printk(KERN_ALERT "Failed to register a major number\n");
        return major_number;
    }

    printk(KERN_INFO "Virtual character device registered with major number %d\n", major_number);
    return 0;
}

// Module cleanup
static void __exit virtual_char_device_exit(void) {
    // Unregister the character device
    unregister_chrdev(major_number, DEVICE_NAME);
    printk(KERN_INFO "Virtual character device unregistered\n");
}

// Called when the device is opened
static int virtual_char_device_open(struct inode *inode, struct file *file) {
    open_count++;
    printk(KERN_INFO "Device opened. Open count: %d\n", open_count);
    return 0;
}

// Called when the device is released
static int virtual_char_device_release(struct inode *inode, struct file *file) {
    open_count--;
    printk(KERN_INFO "Device released. Open count: %d\n", open_count);
    return 0;
}

// Called when data is read from the device
static ssize_t virtual_char_device_read(struct file *file, char __user *user_buffer, size_t count, loff_t *ppos) {
    int bytes_to_copy;
    int remaining_bytes;

    if (*ppos >= BUFFER_SIZE) {
        return 0; // End of file
    }

    remaining_bytes = BUFFER_SIZE - *ppos;
    bytes_to_copy = (count < remaining_bytes) ? count : remaining_bytes;

    if (copy_to_user(user_buffer, &device_buffer[*ppos], bytes_to_copy)) {
        return -EFAULT; // Error copying data to user space
    }

    *ppos += bytes_to_copy;
    return bytes_to_copy;
}

// Called when data is written to the device
static ssize_t virtual_char_device_write(struct file *file, const char __user *user_buffer, size_t count, loff_t *ppos) {
    int bytes_to_copy;
    int remaining_bytes;

    if (*ppos >= BUFFER_SIZE) {
        return -ENOSPC; // No space left on device
    }

    remaining_bytes = BUFFER_SIZE - *ppos;
    bytes_to_copy = (count < remaining_bytes) ? count : remaining_bytes;

    if (copy_from_user(&device_buffer[*ppos], user_buffer, bytes_to_copy)) {
        return -EFAULT; // Error copying data from user space
    }

    *ppos += bytes_to_copy;
    return bytes_to_copy;
}

module_init(virtual_char_device_init);
module_exit(virtual_char_device_exit);

