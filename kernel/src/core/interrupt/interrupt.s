/*--------------------------------------------------------------------
 *  Data definitions – placed in the .data section (read‑write)
 *--------------------------------------------------------------------*/
    .section .data
    .align 2                     /* 4‑byte alignment for RISC‑V */

KEY_STATE:
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .align 2

KEY_TABLE:
    .byte '#', '9', '6', '3', '0', '8', '5', '2', '*', '7', '4', '1', 0
    .align 2

NOTES:
    /* Notes map to keyboard keys */
    .byte 11, 9, 6, 3, 8, 5, 2, 10, 7, 4, 1, 0
    .align 2

CHANGELOG:
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .align 2

/* ISR jump table */
.section .rodata
.align 2                     
.global isr_jump
isr_jump:
    .word isr_0
    .word isr_1
    .word isr_2
    .word isr_3
    .word isr_4          /* Timer has reached its terminal count (at least once) */
    .word isr_5
    .word isr_6
    .word isr_7
    .word isr_8
    .word isr_9
    .word isr_10

/*--------------------------------------------------------------------
 *  Interrupt service routines – placed in the trap section
 *--------------------------------------------------------------------*/
    .section .text.trap
    .align 2

    # .global isr_0, isr_1, isr_2, isr_3
    # .global isr_4, isr_5, isr_6, isr_7, isr_8, isr_9, isr_10

/*--------------------------------------------------------------------
 *  Dummy stubs for the other interrupt vectors (they just return)
 *--------------------------------------------------------------------*/
isr_0:
isr_1:
isr_2:
isr_3:
isr_5:
isr_6:
isr_7:
isr_8:
isr_9:
isr_10:

/*--------------------------------------------------------------------
 *  isr_4 – Timer interrupt (terminal count reached)
 *--------------------------------------------------------------------*/
isr_4:
#     addi    sp, sp, -40          /* allocate space for saved registers */
#     sw      ra, 36(sp)
#     sw      a0, 32(sp)
#     sw      a1, 28(sp)
#     sw      s0, 24(sp)
#     sw      s1, 20(sp)
#     sw      s2, 16(sp)
#     sw      s3, 12(sp)
#     sw      t0, 8(sp)
#     sw      t1, 4(sp)
#     sw      t2, 0(sp)
#
#     /* If 1 is pressed then clear the screen */
#     li      a0, 1
#     call    button_read
#     beqz    a1, update_key_states
#
#     /* Clear the screen */
#     li      a1, 1
#     li      a2, 1
#     call    puts
#
# update_key_states:
#     call    get_keys            /* a0 ← pressed‑key bitmask */
#
#     la      s0, KEY_STATE       /* pointer to debounce history */
#     li      s1, 12              /* number of keys */
#     li      s2, 0               /* current key index */
#     la      s3, CHANGELOG
#
# update_loop:
#     lb      t0, 0(s0)           /* old history for this key */
#     slli    t0, t0, 1           /* shift left (make room for new bit) */
#
#     srl     t1, a0, s2          /* extract current key state */
#     andi    t1, t1, 1
#     or      t0, t0, t1          /* combine */
#     sb      t0, 0(s0)           /* store new history */
#
#     /* if the new history is zero, clear the changelog entry */
#     bnez    t0, continue_update
#     sb      zero, 0(s3)         /* changelog entry = 0 */
#
# continue_update:
#     addi    s0, s0, 1
#     addi    s3, s3, 1
#     addi    s2, s2, 1
#     addi    s1, s1, -1
#     bnez    s1, update_loop
#
#     /* Restart the timer */
#     li      a0, 0x10            /* CLR (clear) value */
#     li      a1, 0x14            /* Control‑Set register offset */
#     # call    timer_write
#
# /*--------------------------------------------------------------------
#  *  Print the keys that are pressed
#  *--------------------------------------------------------------------*/
# numberpunch_start:
#     la      s0, KEY_STATE
#     la      s1, KEY_TABLE
#     li      s2, 0xFF            /* “pressed” sentinel */
#     la      s3, CHANGELOG
#     la      s4, NOTES
#
# numberpunch_print_loop:
#     lbu     t0, 0(s0)           /* current debounce history */
#     bne     t0, s2, numberpunch_print_loop_end
#
#     lbu     t0, 0(s3)           /* changelog for this key */
#     bnez    t0, numberpunch_print_loop_end
#
#     /* key just became pressed – print it */
#     li      t0, 1
#     sb      t0, 0(s3)           /* mark as printed */
#
#     lbu     a1, 0(s1)           /* ASCII character for the key */
#     li      a2, 0               /* do not clear the screen */
#     call    puts
#
#     lbu     t0, 0(s4)           /* note value */
#     li      t1, 0x00020000      /* address of the note peripheral */
#     sw      t0, 0(t1)           /* write note */
#
# numberpunch_print_loop_end:
#     addi    s0, s0, 1
#     addi    s1, s1, 1
#     addi    s3, s3, 1
#     addi    s4, s4, 1
#     lbu     t0, 0(s1)           /* check for terminating zero in KEY_TABLE */
#     bnez    t0, numberpunch_print_loop
#
#     /* Restore registers and return */
#     lw      ra, 36(sp)
#     lw      a0, 32(sp)
#     lw      a1, 28(sp)
#     lw      s0, 24(sp)
#     lw      s1, 20(sp)
#     lw      s2, 16(sp)
#     lw      s3, 12(sp)
#     lw      t0, 8(sp)
#     lw      t1, 4(sp)
#     lw      t2, 0(sp)
#     addi    sp, sp, 40
#     ret
