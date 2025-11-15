INCLUDE trap.s

ORG 0

; ----------------------------------------- Machine Mode Initialisation -----------------------------------------

init
    ; Clear MPP to set U-Mode
    li t0, MPP_BITMASK
    csrc MSTATUS, t0
    
    ; Set the trap vector
    la t0, MHANDLER
    csrw MTVEC, t0
    
    ; Copy `machine` SP for use in handler
    la sp, MSTACK
    csrw MSCRATCH, sp

    ; Change SP to user stack
    li t1, STACK              ; Set the stack address to 0x80000 (this is the end of user memory)
    mv sp, t1                   ; Set the stack pointer to the (user) stack address

    ; Set MEPC to the start of our user program
    la ra, MAIN_START
    csrw MEPC, ra

    ; Enable Interrupts on the Processor
    li t0, 0x8
    csrs MSTATUS, t0            ; Set MIE bit  
    
    ; Enable Machine External Interrupts
    li t0, 0x800                ; Set MPIE bit
    csrs MIE, t0                ; Set bit 11 of mie (Machine External Interrupt)

    ; Enable timer (peripheral) and button interrupts in the external interrupt controller
    ; 0x10 (bit 4) is the timer interrupt
    ; 0x20 (bit 5) is the button interrupt
    li t0, 0x10                    
    la t1, INTERRUPT_CONTROLLER
    sw t0, 4[t1]

    la t0, SC_BITMASK
    la t1, SYSTEM_CONTROLLER
    sw t0, 8[t1]                ; Set pins 6-7 to alternative function

    mret

; Machine Stack
MSTACK_END DEFS 1000 				; Reserve 100 bytes for the stack and point to the end (this is a stack `size` of 25, since each `item` is a word...)
MSTACK


; ------------------------------------------------- CONSTANTS -----------------------------------------------------
MHANDLER EQU 0x0000_2000

INTERRUPT_CONTROLLER EQU 0x0001_0400

SYSTEM_CONTROLLER EQU 0x0001_0700
SC_BITMASK EQU 0x000000C0

; Use CSRC to clear MPP (i.e. for U-Mode)
; Use CSRS to set MPP (i.e. for M-Mode)
MPP_BITMASK   EQU 0x0000_1800

; Main program start address
MAIN_START EQU 0x0004_0000
