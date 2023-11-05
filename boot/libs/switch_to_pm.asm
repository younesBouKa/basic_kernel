BITS 16
; switch to protected mode
switch_to_pm:
    ; print a message 
    mov si, SWITCHING_MSG
    call print_string_rm
    
	cli	; we must switch off interrupts until we have 
		; set up the protected modde interrupt vector
		; otherwise interrupts will run riot
	lgdt [gdt_descriptor] ; load our global descriptor table which define
						  ; the protected mode segments (for code and data)
						 
	mov eax, cr0	; to make switch to protected mode, we set
	or eax, 0x01		; the first bit of CR0, a control register
	mov cr0, eax
	
	jmp CODE_SEG:init_pm ;  make a far jump (to new segment) to our 32-bit
						 ; code, this also forces the CPU to flash its cache
						 ; of pre-fetched and real-mod decoded instruction
						 ; which can cause problems
						 
BITS 32
; initialise registers and stack once in PM
init_pm:
	mov ax, DATA_SEG	; now in PM, our old segment are meaningless
	mov ds, ax			; so we point our segment registers to
	mov ss, ax			; the data selector we defined in our GDT
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ebp, 0x90000 ; update our stack position so it is right
	mov esp, ebp 	 ; at the top of free space
	
	call BEGIN_PM ; start in PM mode
	
; Globale variables
SWITCHING_MSG db "Swithcing to protected mode ...", 0x0a, 0
