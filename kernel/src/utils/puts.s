;-----------------------------------------------------
; puts - write a single character to the HD44780 LCD display.
; A. Aly
; Version 1.0
; 15th February 2024
;
; A library for writing a single character to the HD44780 LCD display.
;
; Last modified: XXX (AA)
;-----------------------------------------------------

; --------------------
;       SIGNALS
; --------------------
; | Data Bus = 8bits |
; --------------------
; |  Control Signals |
; --------------------
; LCD R/W       : Bit 0
; LCD RS        : Bit 1
; LCD E         : Bit 2
; LCD Backlight : Bit 3
; ----------------------------------------------------

INCLUDE delay.s

; Defining some constants for the control register. We always use AND to turn off bits and OR to turn on bits!
enable_on  EQU 0b0100
enable_off EQU 0b1011
rs_on      EQU 0b0010				; Select Data
rs_off     EQU 0b1101				; Select Control
rw_on      EQU 0b0001				; Read a character
rw_off     EQU 0b1110				; Write a character
backlight  EQU 0b1000

; Defining LCD Status byte
busy EQU 0b1000_0000

; Memory-mapped I/O addresses
DATA_BUS EQU 0x0001_0100	
CONTROL  EQU 0x0001_0101	

;-----------------------------------------------------
; Write a character to the screen
; Params:
;   a1: Character to be written
;   a2: Clear Screen Flag
;
;	
;   Clearing the Screen:
;   	- a1: 1
;       - a2: 1
;
;-----------------------------------------------------
puts
	; Save return address and local variables s2 and s3
	subi sp, sp, 12
	sw ra, 8[sp]
    sw s2, 4[sp]
    sw s3, [sp]

    ; Load CONTROL and DATA_BUS addresses into s2 and s3
	la s2, CONTROL
	la s3, DATA_BUS

no_clear
	; Step 1: Set control register for reading busy flag
	lbu t0, CONTROL					    ; read what is in the control already
	andi t0, t0, rs_off					; clear RS bit
	ori t0, t0, rw_on					; set RW bit
	sb t0, [s2]				            ; write back to control with correct bits set

puts_loop
	; Step 2: Enable the bus
	lbu t0, CONTROL					; read what is in the control already
	ori t0, t0, enable_on			; set E bit
	sb t0, [s2]						; write back to control with correct bits set

	; Step 2a: Delay for 500 ns
	li a0, 10                        ; a0 == 1 means a 100 ns delay, so a0 == 5 means 500 ns delay
	call delay						
	
	; Step 3: Read LCD Status Byte (Busy Flag)
	lbu t0, DATA_BUS
	andi t5, t0, busy				; t5 = t0 & 0b1000_0000

	; Step 4: Disable the bus
	lbu t0, CONTROL				; read what is in the control already
	andi t0, t0, enable_off		; clear E bit
	sb t0, [s2]					; write back to control with correct bits set
	
	; Step 5: Delay for 1200 ns
	li a0, 14
	call delay

	; Step 6: If busy flag is set, repeat from Step 2
	bnez t5, puts_loop

	; Step 7: Set control register for writing
	lbu t0, CONTROL
	andi t0, t0, rw_off
	ori t0, t0, rs_on		; set to write data

	beqz a2, continue_puts
	; If a2 is set, we need to clear the screen

	; Now we need a check to see if we need to clear the screen. If a2 is set then rs should be off.
	andi t0, t0, rs_off

continue_puts
	ori t0, t0, backlight
	sb t0, [s2]				; write back to control with correct bits set

	; Step 8: Output the character to the data bus
	sb a1, [s3]

	; Step 9: Enable the bus
	lbu t0, CONTROL
	ori t0, t0, enable_on
	sb t0, [s2]

	; Step 9a: Delay for 500 ns
	li a0, 10
	call delay		

	; Step 10: Disable the bus
	lbu t0, CONTROL
	andi t0, t0, enable_off
	sb t0, [s2]						; write back to control with correct bits set

puts_done
	; Restore return address and local variables and return
	lw ra, 8[sp]								; restore ra
	lw s2, 4[sp]								; restore s2
	lw s3, [sp]									; restore s3
	addi sp, sp, 12								; by popping from the stack		
	ret		
