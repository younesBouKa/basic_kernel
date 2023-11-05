[ORG 0X7c00] ; BIOS load our bootloader at this address in RAM
[BITS 16] ; We start in real mode (16 bits)

; Kernel code will be loaded in thsi address 
; also we have to jump here after switching to protected mode
; this offset can be just after the boot sector
; in this case it can be: 0x7e00 ; 0x7c00+ 512 => 0x7c00+0x200 => 0x7e00
KERNEL_OFFSET equ 0x1000

; Number of sectors to load from boot drive
NBR_OF_SECTORS equ 0x09

; Setting the stack
mov bp, 0x8000 
mov ss, bp
mov sp, bp

; Setting extra segment
mov bx, 0
mov es, bx		

; The bootloader entry point
start:
	; print a message in the real mode
	mov si, MSG_REAL_MODE
	call print_string_rm 
	
	; load kernel from boot drive
	call load_kernel 
	
	; print a message that kernel is loaded
	mov si, MSG_KERNEL_LOADED
	call print_string_rm
	
	; switching to protected mode, 
	; that will prepare CPU and disable interupts then jump to BEGIN_PM
	call switch_to_pm 
	jmp $
	
%include "./boot/libs/print_string_rm.asm"
%include "./boot/libs/gdt.asm"
%include "./boot/libs/print_string_pm.asm"
%include "./boot/libs/switch_to_pm.asm"

; routine for loading kernel code
[BITS 16]
load_kernel:
	mov ah, 0x02 	; BIOS disk read function 
	mov al, NBR_OF_SECTORS	; read DH of sectors 
	mov ch, 0x00	; select cylinder 0
	mov dh, 0x00	; select head 0
	mov cl, 0x02	; start reading from second sector 
					; (after the boot sector)
	mov bx, KERNEL_OFFSET ; destination in memory
	
	int 0x13	; BIOS interubt issus reading
	
	jc kernel_load_error	; jump if error (carry flag set)
	
	ret

kernel_load_error:
	mov si, DISK_ERROR_MSG
	call print_string_rm 
	jmp $
	
; This is where we arrive after switching to and initialising protected mode
[BITS 32]
BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	call print_string_pm
	
	call KERNEL_OFFSET ; start executing kernel code
	
	jmp $ ; hang here

; Global variables
MSG_REAL_MODE db ">Start in 16-bit Real Mode", 0
MSG_KERNEL_LOADED db ">Kernel loaded with success", 0
DISK_ERROR_MSG db ">Error while loading kernel code!", 0
MSG_PROT_MODE db ">Successfully landed in 32-bit Protected Mode", 0

; Bootsector padding with zeros
times 510 - ($ - $$) db 0
dw 0xAA55
