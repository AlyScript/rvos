/*
 * =========================================================================
 * CONSTANTS and ADDRESSES 
 * =========================================================================
 */

.equ MHANDLER,                 0x00002000      /* Trap Vector Address (MTVEC) */
.equ INTERRUPT_CONTROLLER,     0x00010400      /* External Interrupt Controller Address */
.equ SYSTEM_CONTROLLER,        0x00010700      /* System Controller Base Address */
.equ SC_BITMASK,               0x000000C0      /* System Controller Pin Mask */
.equ MPP_BITMASK,              0x00001800      /* MSTATUS[12:11] bits for Machine Previous Privilege Mode */
.equ MAIN_START,               0x00040000      /* User Program Start Address (MEPC) */
.equ USER_STACK_END,           0x00080000      /* User Stack */

/* ----------------------------------------- Machine Mode Initialisation ----------------------------------------- */

.section .text.boot
.global _start
_start:
    /* Clear MPP to set U-Mode */
    li t0, MPP_BITMASK
    csrc mstatus, t0
    
    /* Set the trap vector */
    la t0, MHANDLER
    csrw mtvec, t0
    
    /* Copy `machine` SP for use in handler */
    la sp, MSTACK_END_ADDR
    csrw mscratch, sp              

    la sp, USER_STACK_END       /* Set the (user) stack pointer to the (user) stack address */

    /* Set MEPC to the start of our user program */
    la ra, MAIN_START
    csrw mepc, ra

    /* Enable Interrupts on the Processor */
    li t0, 0x8
    csrs mstatus, t0            /* Set MIE bit */
    
    /* Enable Machine External Interrupts */
    li t0, 0x800                /* Set MPIE bit */
    csrs mie, t0                /* Set bit 11 of mie (Machine External Interrupt) */

    /* Enable timer (peripheral) and button interrupts in the external interrupt controller */
    /* 0x10 (bit 4) is the timer interrupt */
    /* 0x20 (bit 5) is the button interrupt */
    li t0, 0x10                    
    la t1, INTERRUPT_CONTROLLER
    sw t0, 4(t1)

    la t0, SC_BITMASK
    la t1, SYSTEM_CONTROLLER
    sw t0, 8(t1)                /* Set pins 6-7 to alternative function */

    /* Before we return to user application, call a function that will zero the bss section and set up the C runtime */ 
    call zero_bss

    mret

    /* Should probably not reach here, but if we do then just jump back to reset address. */
    j _start

    .size start, .-_start       /* Current address (.) - _start */

/*
 * =========================================================================
 * STACK ADDRESS DEFINITIONS
 * =========================================================================
 */

MSTACK_END_ADDR:
    .word 0
    .equ MSTACK_SIZE, 1000
    .size MSTACK_END_ADDR, MSTACK_SIZE

