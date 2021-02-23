%define ROWS 24
%define COLS 79

;; prints character in al
putchar:
	pusha
	mov ah, 0x0e
	int 0x10
	popa
	ret

;; prints string at bx
print_str:
	pusha
print_str_loop:
	mov al, [bx]
	; end of string?
	cmp al, 0
	je print_str_done
	call putchar
	inc bx
	jmp print_str_loop
print_str_done:
	popa
	ret

;; prints number at dx as hexadecimal
print_hex:
	pusha
	mov cx, 4
print_hex_loop:
	dec cx
	mov ax, dx
	shr dx, 4
	and ax, 0xf

	mov bx, HEX_OUT
	add bx, 2 ; skip '0x'
	add bx, cx

	cmp ax, 0xa
	jl print_hex_set_letter
	add al, 0x27
print_hex_set_letter:
	add al, 0x30
	mov byte [bx], al

	cmp cx, 0
	je print_hex_done
	jmp print_hex_loop
print_hex_done:
	mov bx, HEX_OUT
	call print_str
	popa
	ret
HEX_OUT: db '0x0000', 0

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

;; clears screen
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
