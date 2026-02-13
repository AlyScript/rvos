.equ SPP_BITMASK, 0x100          /* SSTATUS[8] bit for Supervisor Previous Privilege Mode */
.equ SV39, 0x8000000000000000   

.section .text.sys.start
.global _start
_start:
    li t0, SPP_BITMASK 
    csrc sstatus, t0            /* This needs to be 0 so that we jump to U-mode after sret as per the spec. */


    la sp, __mstack_start
    csrw sscratch, sp           /* Better remember to swap this when we trap! */

    la t0, __trap_start
    csrw stvec, t0

    call page_init              /* Create an identity mapping for the first GiB of RAM */
    la t0, __root_pte           /* A (4K page aligned) pointer to the level 2 table */
    srli t0, t0, 12             /* MMU will take the address in SATP and shift it left by 12 bits. So reverse this. */
    li t1, SV39                 /* MODE: Sv39 */
    or t0, t0, t1
    csrw satp, t0               /* mode: Sv39, PPN: (__root_pte >> 12) */
    sfence.vma                  /* Global TLB flush */

    /* Set the (user) stack pointer to the (user) stack address */
    la sp, __ustack_start       

    /* After `sret`, we jump to the address in SEPC. So load main() into it. */
    la ra, main
    csrw sepc, ra

    sret

_end:
    j _end
