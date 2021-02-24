BOOTLOADER=bootloader.bin
KERNEL=kernel.bin
OS_DISK=os.img

all: $(OS_DISK) $(DATA_DISK)

$(OS_DISK): $(BOOTLOADER) $(KERNEL)
	dd if=/dev/zero of=$(OS_DISK) bs=512 count=2880
	dd conv=notrunc if=$(BOOTLOADER) of=$(OS_DISK) bs=512 count=1 seek=0
	dd conv=notrunc if=$(KERNEL) of=$(OS_DISK) bs=512 count=4 seek=1

$(BOOTLOADER): bootloader.asm gdt.asm
	nasm -f bin bootloader.asm -o $@

$(KERNEL): kernel.asm
	nasm -f bin kernel.asm -o $@

.PHONY: run clean
run: $(OS_DISK)
	qemu-system-i386 -gdb tcp::26000 -S -no-reboot -monitor stdio -machine q35 \
	    -drive file=$(OS_DISK),format=raw,index=0,media=disk &
	gdb -q

clean:
	rm *.bin *.img
