.equ SPP_BITMASK, 0x100          /* SSTATUS[8] bit for Supervisor Previous Privilege Mode */

.section .text.sys
.global _start
_start:
    li t0, SPP_BITMASK 
    csrc sstatus, t0            /* This needs to be 0 so that we jump to U-mode after sret as per the spec. */

    la sp, __mstack_start
    csrw sscratch, sp           /* Better remember to swap this when we trap! */

    la t0, __trap_start
    csrw stvec, t0

    /* Set the (user) stack pointer to the (user) stack address */
    la sp, __ustack_start       

    /* After `sret`, we jump to the address in SEPC. So load main() into it. */
    la ra, main
    csrw sepc, ra

    sret

_end:
    j _end
