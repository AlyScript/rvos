ENTRY(_start)

OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf64-littleriscv) /* 64-bit little endian */

SECTIONS
{
    . = 0x0000000080200000; 
    
    .text : ALIGN(4K)
    {
        *(.text.start)
        *(.text)
    }

    .rodata : ALIGN(4K)
    {
        *(.rodata)
    }

    .bss : ALIGN(4K)
    {
        /* __bss_start = .; */
        *(.bss)
        . = ALIGN(4K);
        __root_pte     = .;
        /* __bss_end = .; */
    }

    .data : ALIGN(4K)
    {
        *(.data)
        *(.sdata)
    }

    .stack : ALIGN(16) 
    {
        /* Supervisor Stack */
        . = ALIGN(16);
        __mstack_end = .;
        . += 16K;
        __mstack_start = .;

        /* User/Kernel Task Stack */
        . = ALIGN(16);
        __ustack_end = .;
        . += 1M;
        __ustack_start = .;
    }

    .heap : ALIGN(4K) 
    {
        __heap_start = .;
        . += 120M; 
        __heap_end = .;
    }
}

