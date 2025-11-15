; Convert a binary number to BCD
; Params:
;   a0: The binary number to convert
; Returns:
;   a1: The BCD representation of the binary number
binary_to_bcd
	la t0, dec_table		; Point at conversion table
    mv t1, zero		        ; Zero accumulator
    li t3, 1			    ; Termination value
    j bcd_loop_in		    ; Enter loop

bcd_loop	
    divu	t4, a0, t2		; T4 is next decimal digit
    remu	a0, a0, t2		; A0 is the remainder

    add	t1, t1, t4		    ; Accumulate result
    slli t1, t1, 4		    ; Shift accumulator

    addi t0, t0, 4		    ; Step pointer

bcd_loop_in 
    lw	t2, [t0]		    ; Get next divisor
    bne	t2, t3, bcd_loop	; Termination condition?

bcd_out		
    add	a0, t1, a0		    ; Accumulate result to output
    mv a1, a0
    ret				        ; Return

dec_table	
        defw	1000000000, 100000000, 10000000, 1000000
        defw	100000, 10000, 1000, 100, 10, 1
