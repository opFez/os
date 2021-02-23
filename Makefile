BOOTLOADER=bootloader.o
SECTOR2=sec2.o
OS_DISK=os.img

all: $(OS_DISK) $(DATA_DISK)

$(OS_DISK): $(BOOTLOADER) $(SECTOR2) #(OS)
	dd if=/dev/zero of=$(OS_DISK) bs=512 count=2880
	dd conv=notrunc if=$(BOOTLOADER) of=$(OS_DISK) bs=512 count=1 seek=0
	dd conv=notrunc if=$(SECTOR2) of=$(OS_DISK) bs=512 count=1 seek=1

$(BOOTLOADER): bootloader.asm io.asm cmd.asm
	nasm bootloader.asm -o $@

$(SECTOR2): sec2.asm io.asm
	nasm sec2.asm -o $@

.PHONY: run clean
run: $(OS_DISK)
	qemu-system-i386 -gdb tcp::26000 -S -no-reboot -monitor stdio -machine q35 \
	    -drive file=$(OS_DISK),format=raw,index=0 &
	gdb -q

clean:
	rm *.o *.img
