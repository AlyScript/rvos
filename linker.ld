ENTRY(_start)

OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf64-littleriscv)

PHY_BASE = 0x0000000080200000;
VIRT_BASE = 0xFFFFFFC080200000;
VIRT_OFFSET = VIRT_BASE - PHY_BASE;

SECTIONS
{
    . = VIRT_BASE; 
    
    .text : AT(ADDR(.text) - VIRT_OFFSET) ALIGN(4K)
    {
        *(.text.start)
        *(.text)
    }

    .rodata : AT(ADDR(.rodata) - VIRT_OFFSET) ALIGN(4K)
    {
        *(.rodata)
    }

    .bss : AT(ADDR(.bss) - VIRT_OFFSET) ALIGN(4K)
    {
        *(.bss)
    }

    .data : AT(ADDR(.data) - VIRT_OFFSET) ALIGN(4K)
    {
        *(.data)
        *(.sdata)
    }

    .stack : AT(ADDR(.stack) - VIRT_OFFSET) ALIGN(16) 
    {
        . = ALIGN(16);
        __mstack_end = .;
        . += 16K;
        __mstack_start = .;
    }
}
