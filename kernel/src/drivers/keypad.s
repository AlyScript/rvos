; Keypad driver that reads the value of the keypad and returns a 32-bit pattern in a0 representing the keys pressed.
; Refer to Figure 25.1 in the manual for the keypad matrix. 
; 
; Corrupts: s0, s1, s2, s3, t0, a0
; Called by isr_4, so we preserve all registers except a0.
;    
;   Keyboard Matrix:
;   3 6 9 #
;   2 5 8 0
;   1 4 7 *
;
;   Key 0: 3, Key 1: 6, Key 2: 9, Key 3: #
;   Key 4: 2, Key 5: 5, Key 6: 8, Key 7: 0
;   Key 8: 1, Key 9: 4, Key 10: 7, Key 11: *
;
; ----------- PIO Device --------------|
; -------------------------------------|
; Offset  Register   Access   Function |
;--------------------------------------------------------------------------------------------------------------------------------------------
;  00   | Data       | R/W |  Data register
;  04   | Direction  | R/W |  Pin direction {0 = Output, 1 = Input}
;  08   | Data clear | R/W |  Write 1 clears corresponding data bit
;  0C   | Data set   | R/W |  Write 1 sets corresponding data bit
;
; We will have one of bit 5, 6 or 7 high at a given time. Based on this, we can determine the row of the key pressed.
; We will have one of bit 0, 1, 2 or 3 high at a given time (hopefully). Based on this, we can determine the column of the key pressed.
; We will use this information to determine the key pressed.
;
; -------------------------------------------------------------------------------------------------------------------------------------------

PIO EQU 0x0001_0300     ; The base address of the PIO device

; Returns:
;   a0: A (32) bit pattern representing keys 0-11 pressed
; 
get_keys

    subi sp, sp, 24
    sw s0, 20[sp]
    sw s1, 16[sp]
    sw s2, 12[sp]
    sw s3, 8[sp]
    sw s4, 4[sp]
    sw t0, [sp]

    li s0, PIO          ; Local Variable: Base address of the PIO device

    li s1, 0x400        ; Set the row to 10 (1 << 10 = 0x400)
    li s2, 12           ; How many times we will shift this the column pattern right
    li s3, 0x100        ; The last row we will check
    li s4, 0xF000       ; The mask to get the column value
    li a0, 0            ; The key pattern

    ; Firstly we should set pins 15-12 to input (1) and pins 10-8 to output (0)
    li t0, 0xF000
    sw t0, 4[s0]        ; Set the direction to input

key_loop

    ; // Step 1: Set the row we want to check
    sw s1, 12[s0]       ; Drive the row high using 'Data Set' register

    nop
    nop

    ; // Step 2: Read the value of the keypad at this row
    lw t0, [s0]         ; Read the value of the keypad
    and t0, t0, s4      ; Mask the value to get the 4 column bits
    srl t0, t0, s2      ; Shift the column value to the correct position
    or a0, a0, t0       ; Put the result in a0
    subi s2, s2, 4      ; Decrement shifter by 4

    sw s1, 8[s0]        ; Drive the row low using 'Data Clear' register

li t1, 10    
key_delay
    subi t1, t1, 1
    bnez t1, key_delay

    srli s1, s1, 1      ; Next Row
    bgeu s1, s3, key_loop

    addi sp, sp, 24     ; Restore working registers
    lw s0, 20[sp]
    lw s1, 16[sp]
    lw s2, 12[sp]
    lw s3, 8[sp]
    lw s4, 4[sp]
    lw t0, [sp]

    ret

