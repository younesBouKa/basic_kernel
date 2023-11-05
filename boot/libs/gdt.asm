[BITS 32]
; GDT Global Descriptor Table
gdt_start:

gdt_null: ; the mandatory null descriptor (for addressing fault) (8 bytes)
	dd 0x0 ; define double word (4 bytes) Or two of dd 0x0
	dd 0x0
	
gdt_code: ; the code segment descriptor (8 bytes)
	; base=0x0 (32 bits), limit=0xfffff (20 bits)
	; 1st flags: (present)1 (privilige)00 (descriptor type)1 -> 1001b
	; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
	; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
	dw 0xffff	; limit (bits 0-15)
	dw 0x0		; base (bits 0-15)
	db 0x0		; base (bits 16-23)
	db 10011010b ; 1st flags, type flags
	db 11001111b ; 2nd flags, limit (bits 16-19)
	db 0x0		; base (bit 24-31)
	
gdt_data: ; the data segment descriptor (8 bytes)
	; same as code segment except for the type flags:
	; type flags: (code)1 (expand down)0 (writable)1 (accessed)0 -> 0010b
	dw 0xffff	; limit (bits 0-15)
	dw 0x0		; base (bits 0-15)
	db 0x0		; base (bits 16-23)
	db 10010010b ; 1st flags, type flags
	db 11001111b ; 2nd flags, limit (bits 16-19)
	db 0x0		; base (bits 24--31)
	
gdt_end: ; we use this label to calculate the size of the GDT

; GDT Descriptor
gdt_descriptor:
	dw gdt_end - gdt_start + 1 ; size of GDT less one of the true size
	dd gdt_start			  ; start addresss of GDT
	
; Define some constants for the GDT segment descriptor offsets
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
