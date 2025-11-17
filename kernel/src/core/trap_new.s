/* Trap Handler */
/* Defined in this riscv system to be at 0x0000_2000 */

.equ INTERRUPT_CONTROLLER,  0x00010400
.equ ECALL_MAX,  440

.section .rodata
.align 2
.global ecall_jump
ecall_jump:
    .word ecall_0

/* We assume that it is an interrupt and jump to the exception handler, to minimise latency for an interrupt */

.section .text.trap
.global _mhandler
_mhandler:
    csrrw sp, mscratch, sp                  /* Save User SP, set Machine SP */
    addi sp, sp, -12                        /* Push working registers and ra */
    sw ra, 8(sp)                          
    sw t0, 4(sp)                          
    sw t1, 0(sp)   

    csrr t0, mcause                       /* Get the cause of the trap */
    /*andi t0, t0, 0xF                      Mask to make sure that we are in range  */
    bgez t0, exception_handler            /* If it is a positive number, it is an exception */

/* ------------------------------------------ Interrupt Handling ------------------------------------------ */
    
    la t1, interrupt_table                /* Point to interrupt table */
    andi t0, t0, 0xF                      /* Get the interrupt number */
    slli t0, t0, 2                        /* Multiply by 4 to get the correct offset */
    add t1, t0, t1                        /* Add the offset to the table */
    lw t1, 0(t1)                           /* Load the address of the handler */
    jalr t1                               /* Call the handler we need */

mhandler_exit:

    lw t1, 0(sp)                             
    lw t0, 4(sp)                          
    lw ra, 8(sp)                          
    addi sp, sp, 12                        /* Pop working registers and ra */

    csrrw sp, mscratch, sp                /* Save Machine SP, restore User SP */

    /* Enable interrupts again */
    /* li s9, 0x8 */
    /* csrs MSTATUS, s9                      /* Set MIE bit */

    mret                                  /* Return from trap */

/* ------------------------------------------ Exception Handling ------------------------------------------ */
exception_handler:
    la t1, trap_table                    /* Point to trap table */
    slli t0, t0, 2                       /* Multiply by 4 to get the correct offset */
    add t1, t0, t1                       /* Add the offset to the table */
    lw t1, 0(t1)                          /* Load the address of the handler */
    jalr t1                              /* Call the handler we need */
    
    csrrw t0, mepc, t0                   /* Find the trapping instruction */
    addi t0, t0, 4                       /* Correct to a return address */
    csrrw t0, mepc, t0                   /* Swap back in */

    j mhandler_exit                      /* Return from the exception handler */

/* ----------------------------------------------------------- INTERRUPT TABLE & SERVICE ROUTINES ------------------------------------------------------------ */
.section .rodata
.align 2
.global interrupt_table
interrupt_table:
    .word handle_interrupt_0             /* 0 - User Software Interrupt */
    .word handle_interrupt_1             /* 1 - Supervisor Software Interrupt */
    .word handle_interrupt_2             /* 2 - Reserved */
    .word handle_interrupt_3             /* 3 - Machine Software Interrupt */
    .word handle_interrupt_4             /* 4 - User Timer Interrupt */
    .word handle_interrupt_5             /* 5 - Supervisor Timer Interrupt */
    .word handle_interrupt_6             /* 6 - Reserved */
    .word handle_interrupt_7             /* 7 - Machine Timer Interrupt */
    .word handle_interrupt_8             /* 8 - User External Interrupt */
    .word handle_interrupt_9             /* 9 - Supervisor External Interrupt */
    .word handle_interrupt_10            /* 10 - Reserved */
    .word handle_machine_external        /* 11 - Machine External Interrupt */
    # .byte 0xDE, 0xAD, 0xBE, 0xEF

handle_interrupt_0:
handle_interrupt_1:
handle_interrupt_2:
handle_interrupt_3:
handle_interrupt_4:
handle_interrupt_5:
handle_interrupt_6:
handle_interrupt_7:
handle_interrupt_8:
handle_interrupt_9:
handle_interrupt_10:
handle_machine_external:
    /* Now it`s time to establish which interrupts (remembering that there could be more than one, simultaneously) are active.  */
    /* This involves referring to our own interrupt controller peripheral. */
    /* Interrupt controller is at 0x0001_0400 */

    addi sp, sp, -36                         /* Push working registers and ra to be safe */
    sw ra, 32(sp)
    sw t0, 28(sp)
    sw t1, 24(sp)
    sw t2, 20(sp)
    sw t3, 16(sp)
    sw t4, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    la t0, INTERRUPT_CONTROLLER             /* Load the address of the interrupt controller */
    lw t1, 0(t0)                             /* Read the interrupt status register */

    lw t2, 4(t0)                            /* Read the interrupt enable register */
    and t1, t1, t2                          /* Mask the interrupt status with the interrupt enable */

    beqz t1, handle_machine_external_exit   /* If there are no active interrupts, exit */

find_active_interrupt:
    li s1, 1                              /* Start with LSB */
    li s2, 0                                /* Bit position counter */

check_interrupt:
    and t3, t1, s1                          /* Check if the `s2`th bit (s1) is set */
    bnez t3, handle_interrupt               /* If it is, jump to the interrupt service routine */

    slli s1, s1, 1                          /* Shift the bit to the left */
    addi s2, s2, 1                          /* Increment the bit position counter */
    li t4, 11                               /* Check if we have checked all the bits      */
    blt s2, t4, check_interrupt             /* If we haven`t checked all the bits, check the next one */

    j handle_machine_external_exit

handle_interrupt:
    la s0, isr_jump                         /* Load the address of the interrupt service routine jump table */
    slli s2, s2, 2                          /* Multiply the bit position by 4 to get the correct offset */
    add s0, s2, s0                          /* Add the offset to the table */
    lw s0, 0(s0)                            /* Load the address of the interrupt service routine */
    jalr s0                                 /* Call the interrupt service routine */

handle_machine_external_exit:

    lw s2, 0(sp)                             /* Restore working registers and ra */
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw t4, 12(sp)
    lw t3, 16(sp)
    lw t2, 20(sp)
    lw t1, 24(sp)
    lw t0, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36

    ret

/* ------------------------------------------------------------------ TRAP TABLE & HANDLERS ------------------------------------------------------------------ */

trap_table:
    .word handle_instr_addr_misaligned    /* 0 - Instruction address misaligned */
    .word handle_instr_access_fault       /* 1 - Instruction access fault */
    .word handle_illegal_instr            /* 2 - Illegal instruction */
    .word handle_breakpoint               /* 3 - Breakpoint */
    .word handle_load_addr_misaligned     /* 4 - Load address misaligned */
    .word handle_load_access_fault        /* 5 - Load access fault */
    .word handle_store_addr_misaligned    /* 6 - Store address misaligned */
    .word handle_store_access_fault       /* 7 - Store access fault */
    .word handle_ecall_umode              /* 8 - Environment call from U-mode */
    .word handle_ecall_smode              /* 9 - Environment call from S-mode */
    .word handle_reserved                 /* 10 - Reserved */
    .word handle_ecall_mmode              /* 11 - Environment call from M-mode */
    .word handle_instr_page_fault         /* 12 - Instruction page fault */
    .word handle_load_page_fault          /* 13 - Load page fault */
    .word handle_reserved_future          /* 14 - Reserved for future standard use */
    .word handle_store_page_fault         /* 15 - Store page fault */

handle_instr_addr_misaligned:  
handle_instr_access_fault:     
handle_illegal_instr:          
handle_breakpoint:             
handle_load_addr_misaligned:   
handle_load_access_fault:      
handle_store_addr_misaligned:  
handle_store_access_fault:     

handle_ecall_umode:   
    li t0, ECALL_MAX            /* Check if ecall number is valid */
    /* bgeu a7, t0, ecall_invalid  /* If not, jump to ecall_invalid */ 
    la t0, ecall_jump           /* Load the address of ecall_jump */
    slli t1, a7, 2              /* Multiply ecall number by 4 to get word offset */
    add t0, t0, t1              /* Add the offset to the address */
    lw t0, 0(t0)                /* Load the address of the ecall handler */
    jr t0                       /* Jump to the ecall handler but keep the return address in ra */

handle_ecall_smode:            
handle_reserved:       
handle_ecall_mmode:     
handle_instr_page_fault:      
handle_load_page_fault:       
handle_reserved_future:       
handle_store_page_fault:      

ecall_0:
