ENTRY(_start)

OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf32-littleriscv) /* 32-bit little endian */

MEMORY
{
    SYS (rwx)         : ORIGIN = 0x0,           LENGTH = 16K
    INSTR (rwx)       : ORIGIN = 0x00040000,   LENGTH = 256K
}

SECTIONS
{

    /* Processor reset code needs to be here. */
    .text.boot :
    {
        *(.text.boot)
    }> SYS

    /* Now everything in application memory. */
    .text :
    {
        *(.text)    
    }> INSTR

    .bss : 
    {
        *(.bss)    
    }> INSTR

    .data : 
    {
        *(.data)    
    }> INSTR

    .rodata : 
    {
        *(.rodata)    
    }> INSTR

}

