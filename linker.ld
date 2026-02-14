ENTRY(_start)

OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf64-littleriscv) /* 64-bit little endian */

SECTIONS
{
    . = 0x0000000080200000; 
    
    .sys :
    {
        /* Jump here first in supervisor mode. */
        *(.text.sys.start)

        . = ALIGN(4);
        __trap_start = .;
        *(.text.trap.entry)
        *(.text.trap)
        __trap_end   = .;

        *(.text.sys)

        *(.data.sys)

        /* Machine Stack */
        . = ALIGN(16);
        __mstack_end   = .;
        . += 10K;
        __mstack_start = .;

        . = ALIGN(4K);
        __root_pte     = .;
    }

    /* 1GB away from Kernel. Will start mapping into here. */
    /* . = 0x00000000B0200000;  */

    .text : 
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .bss : 
    {
        __bss_start = .;
        *(.bss)
        __bss_end = .;
    }

    .data :
    {
        *(.data)
        *(.sdata)
    }

    .mem :
    {
        __heap_start = .;
        . += 120M;
        __heap_end = .;

        . = ALIGN(16);
        __ustack_end = .;
        . += 1M;
        __ustack_start = .;
    }
}

