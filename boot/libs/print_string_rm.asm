BITS 16

print_string_rm:	
	mov bh, 0
.loop:
	lodsb
	cmp al, 0
	je .done
	call print_char
	jmp .loop
.done:
	call print_ln
	ret
	
print_char:
	mov ah, 0eh
	int 0x10
	ret
	
print_ln:
	ret
