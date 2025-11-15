; Print a number in BCD format
; Params:
;   a1: The BCD number to print
;
; Local Variables: s0 -> BCD Number
PrintBCD:
    subi sp, sp, 8             ; Save return address
    sw ra, 4[sp]
    sw s0, [sp]

    mv s0, a1                  ; Copy BCD number to local variable

    li t1, 28                  ; Start at highest nibble (28 bits for up to 32-bit BCD)
    li t2, 0                   ; Zero flag to track leading zeroes

PrintBCD_Loop:
    srl t0, s0, t1             ; Shift right to get the current 4-bit nibble
    andi t0, t0, 0xF           ; Mask lower 4 bits (extract single BCD digit)

    beqz t1, PrintBCD_Last     ; If last nibble, print at least one zero
    bnez t0, PrintBCD_Found    ; If non-zero, start printing
    bnez t2, PrintBCD_Found    ; If already printing, print zeros too

    subi t1, t1, 4             ; Move to next nibble
    j PrintBCD_Loop            ; Repeat

PrintBCD_Found:
    li t2, 1                   ; Set flag to print all digits from now
    addi t0, t0, 0x30          ; Convert BCD digit to ASCII
    
    li a7, 65                  ; ECALL 65 = puts (character version)
    mv a1, t0                  ; Move ASCII char to a1
    li a2, 0                   ; Don't clear the screen!
    ecall                      ; Print character

    subi t1, t1, 4             ; Move to next nibble
    bgt t1, zero, PrintBCD_Loop     ; Continue if more nibbles left

PrintBCD_Last:
    li a7, 65                  ; ECALL 65 = puts (character version)
    andi a1, s0, 0xF           ; Mask lower 4 bits (extract single BCD digit)
    addi a1, a1, 0x30          ; Convert BCD digit to ASCII
    li a2, 0                   ; Don't clear the screen!
    ecall                      ; Print character

PrintBCD_Done:
    lw s0, [sp]                ; Restore local variables
    lw ra, 4[sp]               ; Restore return address
    addi sp, sp, 8
    ret