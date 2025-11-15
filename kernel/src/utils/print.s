;-----------------------------------------------------
; print - Print a null-terminated string to the screen
; Arguments:
;   a0: Pointer to the string to be printed
;-----------------------------------------------------

INCLUDE puts.s

print
	; Save return address and saved registers
	subi sp, sp, 8
	sw ra, 4[sp]
	sw s0, [sp]

    mv a1, a0  ; Pointer to string should be in a0 if called from C

	; Move the string pointer from a1 to s0
	mv s0, a1  ; s0 = a1 (pointer to the string)

print_loop
	; Load the current character from the string
	lb a1, [s0]  ; a1 = *s0 (current character)

	; Check if the character is null (end of string)
	beqz a1, done_printing  ; if a1 == 0, we are done

	; Call puts to print the character
	call puts

	; Move to the next character in the string
	addi s0, s0, 1  ; s0++ (increment string pointer)

	; Repeat for the next character
	j print_loop

done_printing
	; Restore saved registers and return address
	lw s0, [sp]
	lw ra, 4[sp]
	addi sp, sp, 8
	ret
