.kernel:
extern kmain
bits 32
	; mov di, 0x1000
	call kmain

	jmp $ ; kernels returned, shouldn't happen
