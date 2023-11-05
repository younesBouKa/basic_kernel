ORG 0X7c00
BITS 16

KERNEL_OFFSET equ 0x7c00+512 ; our kernel offset

start:
	mov [BOOT_DRIVE], dl ; BIOS store boot drive in dl
	
	mov bp, 0x8000 ; setting the stack
	mov ss, bp
	mov sp, bp
	
	mov bx, 0
	mov es, bx		; setting extra segment
	
	mov si, MSG_REAL_MODE
	call print_string_rm ; print a message in the real mode
	
	call load_kernel ; load kernel from drive
	
	;call switch_to_pm ; switching to protected mode
	
	jmp $
	
%include "./libs/print_string_rm.asm"
%include "./libs/gdt.asm"
%include "./libs/print_string_pm.asm"
%include "./libs/switch_to_pm.asm"
%include "./libs/disk_load.asm"

BITS 16
load_kernel:
	mov bx, KERNEL_OFFSET ; destination of kernel code
	mov dx, 15 ; load 15 sector 
	mov dl, BOOT_DRIVE ; from boot drive
	call disk_load;
	ret

BITS 32
; This is where we arrive after switching to and initialising protected mode
BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	call print_string_pm
	
	call KERNEL_OFFSET ; start executing kernel code
	
	jmp $ ; hang here

; Global variables
BOOT_DRIVE db 0 ; variable to hold boot drive	
MSG_REAL_MODE db "Start in 16-bit Real Mode ", 0
MSG_PROT_MODE db "Successfully landed in 32-bit Protected Mode ", 0

; Bootsector padding 
times 510 - ($ - $$) db 0
dw 0xAA55
