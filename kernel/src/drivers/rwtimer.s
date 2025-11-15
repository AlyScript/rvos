;-----------------------------------------------------
; rwtimer - Read and write to the timer
; A. Aly
; Version 1.0
; 26th February 2024
;
; A library for read/write operations to the timer peripheral on the board.
;
; Last modified: XXX (AA)
;-----------------------------------------------------

TIMER_BASE EQU 0x0001_0200  ; The base address of the timer peripheral

;-----------------------------------------------------
; Read a value from the timer
; Params:
;   a1: offset (in bytes) from the timer base address (see table 15.1) for the register to read
; Returns:
;   a0: The value of the specified timer register
;-----------------------------------------------------
timer_read
    subi sp, sp, 4
    sw ra, [sp]
    
    la a0, TIMER_BASE       ; Load the timer base address into a0
    add a0, a0, a1          ; Calculate the address of the register we want to read
    lw a0, [a0]             
    
    lw ra, [sp]
    addi sp, sp, 4
    ret

;-----------------------------------------------------
; Write a value to the timer
; Params:
;   a0: value to write
;   a1: offset (in bytes) from the timer base address (see table 15.1) for the register to write
;-----------------------------------------------------
timer_write
    subi sp, sp, 4
    sw ra, [sp]
    
    la t0, TIMER_BASE       ; Load the timer base address into t0
    add a1, t0, a1          ; Calculate the address of the register we want to write
    sw a0, [a1]             ; Write the value to the register    
    
    lw ra, [sp]
    addi sp, sp, 4
    ret