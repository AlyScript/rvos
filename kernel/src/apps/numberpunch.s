; Keypad Application for Matrix Keyboard in the Lab
; Known Bugs: None

ORG 0x0004_2000

j numberpunch

numberpunch

    ; Clear the screen first
    li a1, 1
    li a2, 1
    li a7, 65
    ecall

    ; All we do is go through the keys and print them out if the bytes are 0xFF, since this means the key is pressed
    ; get_keys returns the keys in the order 0-11
    ; KEY_STATE is a 12 byte array that stores the history of the keys 0 to 11
    
    ; Set the Modulo / Repeat Bit
    li a7, 66                                   ; ECALL 66 = timer_write
    li a0, 0x2                                  ; MOD (Modulo) on Timer Peripheral
    li a1, 0x14                                 ; Load the offset for the 'Control Set' register into a1
    ecall                                       ; Write 1 to the control register

    ; Set the Timer Limit
    li a7, 66                                   ; ECALL 66 = timer_write
    li a0, 1000                                 ; Load the limit into a0 (we will write this to the limit register)
    li a1, 4                                    ; Load the offset for the limit register into a1
    ecall                                       ; Write the limit to the limit register

    ; Enable the interrupt output
    li a7, 66
    li a0, 0x8                                  ; IEN (Interrupt Enable Bit) on Timer Peripheral
    li a1, 0x14                                 ; We want to set this bit, so we use the 'Control Set' Register
    ecall 

    ; Start the timer
    ; This is done by writing a 1 to the control register which is at offset 0x0C (instead we use the control set register)
    li a7, 66                                   ; ECALL 66 = timer_write
    li a0, 1                                    ; Load 1 into a0 (we will write this to the control register)
    li a1, 0x14                                 ; Control Set Register
    ecall                                       ; Set the EN(able) bit in the control register

loop
    j loop

    ret

; ------------------------------------------------------------------------------------------------------------------------------
; Keyboard Matrix
; Key 0: '#'     Key 1: '9'     Key 2:  '6'     Key 3:  '1'
; Key 4: '0'     Key 5: '8'     Key 6:  '5'     Key 7:  '2'
; Key 8: '*'     Key 9: '7'     Key 10: '4'     Key 11: '1'
