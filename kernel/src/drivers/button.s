; A library to read the value from a button peripheral on the board.
; A. Aly
; Version 1.0

; Params: 
;   a0: The button number (1 - 4)
; Returns:
;   a1: The value of the button (0 or some value > 0)
;-----------------------------------------------------
;
; 

BUTTON_BASE EQU 0x0001_0001

; Button 1: Value 1
; Button 2: Value 2
; Button 3: Value 4
; Button 4: Value 8

button_read
    li a1, BUTTON_BASE          ; Load the button base address into a1
    lbu a1, [a1]                ; Get the bit patten at the button base
    subi a0, a0, 1              ; Decrement the button number by 1
    li t0, 1
    sll t0, t0, a0              ; Shift 1 left by the button number
    and a1, a1, t0              ; Check if the button specified in a0 is pressed
    ret
;-----------------------------------------------------    
    