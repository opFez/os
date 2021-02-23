org 0x7c00
bits 16
jmp boot

%include "gdt.asm"

boot:
	cli ; no hardware interrupts

	call clear_scr
	mov ax, 0x100
	mov es, ax

	xor bx, bx
	mov ah, 0x02
	mov al, 4
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0x80
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

	mov [0xb8000], byte 'a'
	jmp CODE_SEG:0x1000

	jmp hang

bits 16
sec2_load_error:
	mov ah, 0x0e
	mov al, 'e'
	int 0x10
	jmp hang

;; io code (clear screen)
%define ROWS 24
%define COLS 79
clear_scr:
	pusha
	xor dx, dx
	; bx specifies page or smth
	xor bx, bx

	; put cursor to topleft
	mov ah, 0x02
	int 0x10
	; ready for printing
	mov ah, 0x0e
	mov al, ' '
clear_scr_loop:
	; write spaces until at the end of page
	cmp dh, ROWS
	je clear_scr_finished
	cmp dl, COLS
	je clear_scr_newline

	add dl, 1
	int 0x10
	jmp clear_scr_loop
clear_scr_newline:
	call newline
	xor dl, dl
	add dh, 1
	jmp clear_scr_loop
clear_scr_finished:
	mov ah, 0x02
	xor dx, dx
	int 0x10

	popa
	ret

;; prints \r\n
newline:
	pusha
	mov ah, 0x0e
	mov al, 0x0d
	int 0x10
	mov al, 0x0a
	int 0x10
	popa
	ret



hang:
	jmp $

times 510 - ($-$$) db 0
dw 0xaa55 ; boot signature
