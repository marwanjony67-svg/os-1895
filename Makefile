CC = gcc
LD = ld
NASM = nasm

CFLAGS = -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -fno-asynchronous-unwind-tables -O2 -Wall -Wextra
LDFLAGS = -m elf_i386 -nostdlib -static -T linker.ld

BUILD_DIR = build
ISO_ROOT = $(BUILD_DIR)/iso_root
KERNEL = $(BUILD_DIR)/kernel.elf
ISO = $(BUILD_DIR)/os-1895.iso

all: $(ISO)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/multiboot_entry.o: src/multiboot_entry.asm | $(BUILD_DIR)
	$(NASM) -f elf32 $< -o $@

$(BUILD_DIR)/kernel.o: src/kernel.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL): $(BUILD_DIR)/multiboot_entry.o $(BUILD_DIR)/kernel.o linker.ld
	$(LD) $(LDFLAGS) $(BUILD_DIR)/multiboot_entry.o $(BUILD_DIR)/kernel.o -o $@

$(ISO_ROOT)/boot/grub: $(KERNEL) grub/grub.cfg | $(BUILD_DIR)
	mkdir -p $(ISO_ROOT)/boot/grub
	cp grub/grub.cfg $(ISO_ROOT)/boot/grub/grub.cfg
	cp $(KERNEL) $(ISO_ROOT)/boot/kernel.elf

$(ISO): $(ISO_ROOT)/boot/grub
	grub-mkrescue -o $@ $(ISO_ROOT) > /dev/null

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
