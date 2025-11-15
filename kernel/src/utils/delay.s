;-----------------------------------------------------
; delay - Software delay loop
; Arguments:
;   a0: Number of iterations for the delay
;-----------------------------------------------------
delay
	addi a0, a0, -1
	bnez a0, delay
	ret