OUTPUT_ARCH("riscv")
ENTRY(_ustart)

SECTIONS
{
    /* Start the binary at virtual address 0x0 */
    . = 0x0;

    .text : {
        /* Force the entry section to be the absolute first thing */
        *(.text.entry)
        *(.text .text.*)
    }

    .rodata : {
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
    }

    .data : {
        *(.data .data.*)
        *(.sdata .sdata.*)
    }

    .bss : {
        *(.bss .bss.*)
        *(.sbss .sbss.*)
    }
}
