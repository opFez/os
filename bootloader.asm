; handled by link.ld
;org 0x7c00
bits 16
	jmp boot

%include "gdt.asm"

boot:
	cli ; no hardware interrupts

	call set_video_mode ; sets video mode
	                    ; also clears screen

	mov ax, 0x100
	mov es, ax

	xor bx, bx
	mov ah, 0x02
	mov al, 4
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0x80 ; this is for floppy. apparently it's just 0 for hard drives
	clc
	int 0x13
	jc sec2_load_error

	;; 32 bit
	; enable a20
	in al, 0x92
	or al, 2
	out 0x92, al

	; set gdt descriptor
	lgdt [gdt_descriptor]
	; enable protected mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	; far jump to flush cpu
	jmp CODE_SEG:start_pm

bits 32
start_pm:
	; update segment registers
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; jump to sector 2 of our floppy
	jmp CODE_SEG:0x1000

	jmp hang

bits 16
sec2_load_error:
	mov ah, 0x0e
	mov al, 'e'
	int 0x10
	jmp hang

;; clear screen by switching to text mode 1 and back to 3
set_video_mode:
	pusha
	mov ah, 0
	mov al, 1
	int 0x10
	; we're using 80*25 16 color text mode
	mov al, 3
	int 0x10
	popa
	ret

hang:
	jmp $

times 510 - ($-$$) db 0
dw 0xaa55 ; boot signature
