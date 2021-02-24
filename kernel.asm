bits 32
	mov [0xb8000], byte 'b'
	mov [0xb8001], byte 0x4f

	
	jmp $ ; hanging
