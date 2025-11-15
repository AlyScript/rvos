; A stopwatch programme which increments a value on the display once per second using the hardware timer as a reference.
; 
; Local Variables: 
;   s0: stopwatch count
; Button:
;   1: Count
;   2: Pause
;   3: Reset
;
; State Machine:
;   S0: Reset
;   S1: Running
;   S2: Paused
;
;   S0 -> S1 from Button 1
;   S1 -> S2 from Button 2
;   S2 -> S0 from Button 3
;   S2 -> S1 from Button 1


ORG 0x0004_1000

j stopwatch

INCLUDE ../utils/conversions.s
INCLUDE ../utils/printbcd.s

; Constants
LIMIT EQU 1_000_001
; // 1 Second --> 1_000_000 \\

; Button:
;   1: Count
;   2: Pause
;   3: Reset
stopwatch
    ; S0: Counter = 0
    ; S1: Read Counter value
    ; S2: Pause Counter    

    ; S0 -> S1 from Button 1
    ; S1 -> S2 from Button 2
    ; S2 -> S0 from Button 3
    ; S2 -> S1 from Button 1

    ; Set the Modulo / Repeat Bit
    li a7, 66                       ; ECALL 66 = timer_write
    li a0, 0x2                      ; MOD (Modulo) on Timer Peripheral
    li a1, 0x14                     ; Load the offset for the 'Control Set' register into a1
    ecall                           ; Write 1 to the control register

    ; Set the Timer Limit
    li a7, 66                       ; ECALL 66 = timer_write
    li a0, LIMIT                    ; Load the limit into a0 (we will write this to the limit register)
    li a1, 4                        ; Load the offset for the limit register into a1
    ecall                           ; Write the limit to the limit register

    ; Enable the interrupt output
    li a7, 66
    li a0, 0x8                      ; IEN (Interrupt Enable Bit) on Timer Peripheral
    li a1, 0x14                     ; We want to set this bit, so we use the 'Control Set' Register
    ecall 

stopwatch_reset
    ; First we begin in S0. Any timer operations MUST be done via an ECALL.

    li s0, 0                        ; Initialise the stopwatch counter to 0

    call clear_stopwatch_screen     ; We will first clear the screen before printing anything to it

    ; Print '0' to the screen (resetting the counter)
    li a7, 65                       ; ECALL 65 = puts
    la a1, 0x30                     ; load ASCII for '0' into a1
    li a2, 0
    ecall

    ; Also ensure that MSB of control register is cleared
    li a7, 66                       ; ECALL 66 = timer_write
    li a0, 0x80000000               ; BitMask to clear the MSB
    li a1, 0x10                     ; Control Clear Register
    ecall

poll_start_button
    li a7, 0                        ; ECALL 0 = Read Button
    li a0, 1                        ; Button 1
    ecall

    beqz a1, poll_start_button      ; If Button 1 is not pressed, go back

start_timer
    ; This is S1. We are counting. We will continuously read the counter value and display it.

    ; First we need to start the counter
    ; This is done by writing a 1 to the control register which is at offset 0x0C (instead we use the control set register)
    li a7, 66                       ; ECALL 66 = timer_write
    li a0, 1                        ; Load 1 into a0 (we will write this to the control register)
    li a1, 0x14                     ; Control Set Register
    ecall                           ; Set the EN(able) bit in the control register

count
    ; First we need to check if the pause button has been pressed
    li a7, 0                        ; ECALL 0 = Read Button
    li a0, 2                        ; Button 2
    ecall                           ; Read Button 2
    bne a1, zero, pause             ; If Button 2 is pressed, move to paused state

    ; Also check if the reset button has been pressed
    li a7, 0                        ; ECALL 0 = Read Button
    li a0, 3                        ; Button 3
    ecall
    bne a1, zero, stopwatch_reset   ; If Button 3 is pressed, reset the counter

    j count                         ; Continue counting

pause
    ; Two things can happen here:
    ; 1. The reset button is pressed, in which case we reset the counter
    ; 2. The start button is pressed, in which case we move back to the counting state

    ; First we need to pause the counter
    li a7, 66                       ; ECALL 66 = timer_write
    li a0, 1                        ; Enable Bit
    li a1, 0x10                     ; Control Clear Register
    ecall                           ; Clear the EN(able) bit in the control register

pause_loop
    li a7, 0                        ; ECALL 0 = Read Button
    li a0, 1                        ; Button 1
    ecall
    bne a1, zero, start_timer       ; If Button 1 is pressed, move back to counting state

    ; If Button 1 is not pressed, check if Button 3 is pressed
    li a7, 0                        ; ECALL 0 = Read Button
    li a0, 3                        ; Button 3
    ecall
    bne a1, zero, stopwatch_reset   ; If Button 3 is pressed, reset the counter

    j pause_loop                    ; Otherwise, remain in paused state

clear_stopwatch_screen
    li a7, 65                       ; ECALL 65 = puts
    la a1, 1                        
    la a2, 1                        ; Set clear screen flag
    ecall                           ; Clear the screen
    
    ret