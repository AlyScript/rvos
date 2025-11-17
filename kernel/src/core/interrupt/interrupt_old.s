INCLUDE interrupts.s

KEY_STATE   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
ALIGN

KEY_TABLE   DEFB        '#', '9', '6', '3', '0', '8', '5', '2', '*', '7', '4', '1', 0
ALIGN

NOTES       DEFB        11, 9, 6, 3, 8, 5, 2, 10, 7, 4, 1, 0                                    ; Notes map to keyboard keys
ALIGN

CHANGELOG   DEFB        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0                                      ; 0 - Ok to print, 1 - Already printed
ALIGN

isr_0:
isr_1:
isr_2:
isr_3:

; Timer has reached its terminal count (at least once)
isr_4:
    subi sp, sp, 40     ; Save (ALL) working registers and ra

    sw ra, 36[sp]
    sw a0, 32[sp]
    sw a1, 28[sp]
    sw s0, 24[sp]
    sw s1, 20[sp]
    sw s2, 16[sp]
    sw s3, 12[sp]
    sw t0, 8[sp]
    sw t1, 4[sp]
    sw t2, [sp]

    ; If 1 is pressed then clear the screen
    li a0, 1
    call button_read
    beqz a1, update_key_states

    ; Clear the screen
    li a1, 1
    li a2, 1
    call puts

update_key_states
    call get_keys       ; Get the Keys that have been pressed
    ; Now we have in a0 the keys that have been pressed

    li s0, KEY_STATE    ; Pointer to first debounce-history byte
    li s1, 12           ; Number of keys
    li s2, 0            ; Index of the key we are currently processing
    li s3, CHANGELOG
    
update_loop
    lb t0, [s0]         ; Load the old history for this key
    slli t0, t0, 1      ; Shift the history left

    srl t1, a0, s2      ; Extract the current state of the key
    andi t1, t1, 1      ; Mask the key state

    or t0, t0, t1       ; Add the new key state to the history
    sb t0, [s0]         ; Store the new history

    ; if the new history is 0, we can put the changelog to 0
    bnez t0, continue_update_loop
    
    li t1, 0
    add t2, s3, s2 
    sb t1, [t2]         ; Set the changelog to 0

continue_update_loop
    addi s0, s0, 1      ; Move to the next history byte
    subi s1, s1, 1      ; Decrement the number of keys left to process
    addi s2, s2, 1      ; Move to the next key

    bnez s1, update_loop
    
    li a0, 0x10         ; 'CLR' (Clear) on Timer Peripheral
    li a1, 0x14         ; Write a 1 using 'Control Set' register
    call timer_write    ; Restart the timer


; ------------------- Print the keys that are pressed ------------------------
numberpunch_start
    la s0, KEY_STATE
    la s1, KEY_TABLE
    li s2, 0xFF
    li s3, CHANGELOG
    li s4, NOTES
numberpunch_print_loop
    lbu t0, [s0]                                ; Load the key state
    bne t0, s2, numberpunch_print_loop_end      ; If the key is not pressed (i.e. Status Byte != 0xFF), skip to the end of the loop
    
    lbu t0, [s3]                                ; Load the change log
    bnez t0, numberpunch_print_loop_end         ; If the key has already been printed, skip to the end of the loop

    li t0, 1
    sb t0, [s3]                                 ; Set the changelog to 1 (key has been printed)

    ; Print the key
    lbu a1, [s1]                                ; Load the ASCII for the key
    li a2, 0                                    ; We dont want to clear the screen
    call puts

    lbu t0, [s4]
	li t1, 0x0002_0000
	sw t0, [t1]	    

numberpunch_print_loop_end
    addi s0, s0, 1                              ; Increment pointers
    addi s1, s1, 1
    addi s3, s3, 1
    addi s4, s4, 1
    lbu t0, [s1]
    bnez t0, numberpunch_print_loop             ; Loop until we reach the end of the table

    lw ra, 36[sp]
    lw a0, 32[sp]
    lw a1, 28[sp]
    lw s0, 24[sp]
    lw s1, 20[sp]
    lw s2, 16[sp]
    lw s3, 12[sp]
    lw t0, 8[sp]
    lw t1, 4[sp]
    lw t2, [sp]
    addi sp, sp, 40                             ; Restore working registers and ra

    ret

isr_5:
isr_6:
isr_7:
isr_8:
isr_9:
isr_10:
