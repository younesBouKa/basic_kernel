BITS 32
; define some constantes
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

; print a null-terminated string pointed to EBX
print_string_pm:
	pusha
	mov edx, VIDEO_MEMORY ; set EDX to the start of vid mem
	
print_string_pm_loop:
	mov al, [ebx] ; store the char at EBX in AL
	mov ah, WHITE_ON_BLACK ; store the attribute for the current char
	
	cmp al, 0 ; are we getting to the end of string ?
	je done
	
	mov [edx], ax ; store char and attri at current charactere cell
	
	add ebx, 1 ; increment EBX to next char in string
	add edx, 2 ; move to next character cell in vid mem
	
	jmp print_string_pm_loop
	
done:
	popa
	ret ; return from function
