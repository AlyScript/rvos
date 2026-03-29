.equ SPP_BITMASK,     0x100
.equ SV39,            0x8000000000000000   
.equ VIRT_OFFSET,     0xFFFFFFC000000000 
.equ KMEM_END,        0xC0000000          /* End of the 1GiB gigapage belonging to the kernel */

.section .text.start
.global _start
_start:
    mv s0, a0   /* hartid */
    mv s1, a1   /* device tree blob address in memory */
                /* see https://github.com/riscv-software-src/opensbi/blob/master/docs/firmware/fw.md */

    li t0, SPP_BITMASK 
    csrc sstatus, t0            

    la sp, __mstack_start
    csrw sscratch, sp           

    la t0, __shandler
    csrw stvec, t0

    /* Create both an identity mapping AND a higher half mapping. */
    call page_init              
    la t0, __root_pte           
    srli t0, t0, 12             
    li t1, SV39                 
    or t0, t0, t1
    csrw satp, t0               
    sfence.vma                  

    /* Move sp over to higher half too */
    li t0, VIRT_OFFSET
    add sp, sp, t0

    /* Need a jump to be in virtual address now. */
    /* __vaddr_jump will be at a high address. */

    la t0, __vaddr_jump
    li t1, VIRT_OFFSET
    add t0, t0, t1
    jr t0

__vaddr_jump:

    /* Remove identity mapping and also populate the free list. */
    /* We're putting the start of "user ram" into a0 and the end (4GiB away) into a1 
       which correspond to `mem_start` and `mem_and`. */
    li a0, KMEM_END

    li t0, 3          /* Map 3GiB for users */
    slli t0, t0, 30

    add a1, a0, t0
    call pm_init

    mv a0, s0
    mv a1, s1
    call kmain

_end:
    j _end
