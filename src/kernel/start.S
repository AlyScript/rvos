.equ SPP_BITMASK, 0x100
.equ SV39, 0x8000000000000000   
.equ VIRT_OFFSET, 0xFFFFFFC000000000 /* Adjust if your offset is different */

.section .text.start
.global _start
_start:
    li t0, SPP_BITMASK 
    csrc sstatus, t0            

    la sp, __mstack_start
    csrw sscratch, sp           

    la t0, __shandler
    csrw stvec, t0

    call page_init              
    la t0, __root_pte           
    srli t0, t0, 12             
    li t1, SV39                 
    or t0, t0, t1
    csrw satp, t0               
    sfence.vma                  

    /* Need a jump to be in virtual address now. */
    /* __vaddr_jump will be at a high address. */
    la t0, __vaddr_jump
    li t1, VIRT_OFFSET
    add t0, t0, t1
    jr t0

__vaddr_jump:

    /* Remove identity mapping */
    call pm_init

    /* TODO; Change this */
    li t0, 0xFFFFFFC000000000
    add sp, sp, t0

    la ra, main
    li t0, 0xFFFFFFC000000000
    add ra, ra, t0
    csrw sepc, ra

    sret

_end:
    j _end
