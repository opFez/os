CROSS=cross/bin/i386-elf-
CC=$(CROSS)gcc
LD=$(CROSS)ld
AS=nasm

BOOTLOADER=bootloader.o
KERNEL=kernel.o
OS=os.bin
OS_DISK=os.img

all: $(OS_DISK) $(DATA_DISK)

$(OS_DISK): $(OS)
	dd if=/dev/zero of=$(OS_DISK) bs=512 count=2880
	# dd conv=notrunc if=$(BOOTLOADER) of=$(OS_DISK) bs=512 count=1 seek=0
	# dd conv=notrunc if=$(KERNEL) of=$(OS_DISK) bs=512 count=4 seek=1
	dd conv=notrunc if=$(OS) of=$(OS_DISK) bs=512 count=4 seek=0

$(OS): $(BOOTLOADER) $(KERNEL)
	# $(LD) -melf_i386 -T link.ld $(BOOTLOADER) $(KERNEL) -o $@ --oformat binary
	$(LD) -melf_i386 -Ttext 0x7c00 $(BOOTLOADER) -o $@.1.o --oformat binary
	$(LD) -melf_i386 -Ttext 0x100 $(KERNEL) -o $@.2.o --oformat binary
	cat $@.1.o $@.2.o > $@

$(BOOTLOADER): bootloader.asm gdt.asm
	$(AS) -felf32 bootloader.asm -o $@

$(KERNEL): kernel.asm
	$(AS) -felf32 kernel.asm -o $@

.PHONY: run clean
run: $(OS_DISK)
	qemu-system-i386 -gdb tcp::26000 -S -no-reboot -monitor stdio -machine q35 \
	    -drive file=$(OS_DISK),format=raw,index=0,media=disk &
	gdb -q

clean:
	rm *.bin *.img *.o
