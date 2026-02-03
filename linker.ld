ENTRY(_start)

OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf64-littleriscv) /* 64-bit little endian */

SECTIONS
{
    . = 0x0000000080200000; 
    
    .sys :
    {
        /* Jump here first in supervisor mode. */
        *(.text.sys)

        . = ALIGN(4);
        __trap_start = .;
        *(.text.trap.entry)
        *(.text.trap)
        __trap_end   = .;

        . = ALIGN(16);

        /* Machine Stack */
        __mstack_end   = .;
        . += 10K;
        __mstack_start = .;
    }

    /* Now everything in application memory. */
    .usr :
    {
        *(.text)

        __bss_start = .;
        *(.bss)
        __bss_end = .;

        *(.data)

        __heap_start = .;
        . += 2M;
        __heap_end = .;

        __ustack_end = .;
        . += 2M;
        __ustack_start = .;
    }
}

