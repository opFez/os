.kernel:
bits 32

	mov [0xb8000], byte 'b'
	mov [0xb8001], byte 0xf0
	jmp $


; 	jmp echoloop

; echoloop:
; 	in al, 0x60
; 	mov [0xb8000], byte al
; 	mov [0xb8001], byte 0x0f
; 	jmp echoloop
	
; 	jmp $ ; hanging

; kisr:
; 	pusha

; 	in al, 0x60 ; read information from kb

; ;;;; HANDLE KEYCODE HERE
 

; 	mov al, 0x20
; 	out 0x20, al ; acknowledge interrupt to PIC
; 	popa
; 	iret
