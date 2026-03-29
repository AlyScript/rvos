/* Function pointers to exception and interrupt handlers */
.extern __etable
.extern __itable
.section .rodata
.align 3
__table:
    .dword __etable
    .dword __itable

.section .text
.align 2
.global __shandler
__shandler:
    /* Swap to supervisor stack. */ 
    csrrw sp, sscratch, sp
    
    /* Save all state. */ 
    addi sp, sp, -272
    sd x1,  8(sp)    

    /* User sp is in sscratch */
    csrr x1, sscratch 
    sd x1, 16(sp)

    sd x3,  24(sp)   
    sd x4,  32(sp)   
    sd x5,  40(sp)   
    sd x6,  48(sp)   
    sd x7,  56(sp)   
    sd x8,  64(sp)  
    sd x9,  72(sp)  
    sd x10, 80(sp)  
    sd x11, 88(sp)  
    sd x12, 96(sp)  
    sd x13, 104(sp) 
    sd x14, 112(sp) 
    sd x15, 120(sp) 
    sd x16, 128(sp) 
    sd x17, 136(sp) 
    sd x18, 144(sp)  
    sd x19, 152(sp)  
    sd x20, 160(sp)  
    sd x21, 168(sp)  
    sd x22, 176(sp)  
    sd x23, 184(sp)  
    sd x24, 192(sp)  
    sd x25, 200(sp)  
    sd x26, 208(sp)  
    sd x27, 216(sp)  
    sd x28, 224(sp)  
    sd x29, 232(sp)  
    sd x30, 240(sp)  
    sd x31, 248(sp)  

    /* CSRs */
    csrr t0, sepc
    sd t0, 256(sp)
    csrr t0, sstatus
    sd t0, 264(sp)

    /* Multiplexing for right handler (interrupt or exception) */
    csrr t0, scause
    srli t0, t0, 63                       /* 1 if interrupt, else 0 */
    slli t0, t0, 3                        /* ecall handler is offset 0, interrupt offset 1. Addresses are 8 bytes. */
    la t2, __table      
    add t2, t2, t0                        /* Offset into the correct table */

    ld t0, 0(t2)                          /* Dereference t2 get address of table */

    csrr t2, scause                       
    slli t2, t2, 1                        /* Get rid of MSB */
    srli t2, t2, 1                        /* -------------- */
    slli t2, t2, 3                        /* Multiply by 8 to get actual offset from __etable */
    add t2, t0, t2                        /* Get pointer to right handler */
    ld t0, 0(t2)                          /* Dereference pointer to get address of handler */

    mv a0, sp                             /* Pass pointer to current stack frame as first argument */
    jalr t0                               /* Jump to handler */

.global switch_to_user
switch_to_user:
    mv sp, a0

    /* Restore all regs */
    /* CSRs First */
    ld t0, 256(sp)
    csrw sepc, t0
    ld t0, 264(sp)
    csrw sstatus, t0

    /* General Regs */
    ld x1,  8(sp)

    /* Restore saved user sp. Mostly used for switching between processes. */
    /* x3 can be safely clobbered since we are restoring it next */
    ld x3, 16(sp)
    csrw sscratch, x3

    ld x3,  24(sp)
    ld x4,  32(sp)
    ld x5,  40(sp)
    ld x6,  48(sp)
    ld x7,  56(sp)
    ld x8,  64(sp)
    ld x9,  72(sp)
    ld x10, 80(sp)
    ld x11, 88(sp)
    ld x12, 96(sp)
    ld x13, 104(sp)
    ld x14, 112(sp)
    ld x15, 120(sp)
    ld x16, 128(sp)
    ld x17, 136(sp)
    ld x18, 144(sp)
    ld x19, 152(sp)
    ld x20, 160(sp)
    ld x21, 168(sp)
    ld x22, 176(sp)
    ld x23, 184(sp)
    ld x24, 192(sp)
    ld x25, 200(sp)
    ld x26, 208(sp)
    ld x27, 216(sp)
    ld x28, 224(sp)
    ld x29, 232(sp)
    ld x30, 240(sp)
    ld x31, 248(sp)

    /* get stuck in an infinite loop if we don't do this */
    # csrrw t0, sepc, t0
    # addi t0, t0, 4                       
    # csrrw t0, sepc, t0

    addi sp, sp, 272
    csrrw sp, sscratch, sp /* Restore user sp */
    sret
