ENTRY(_start)

OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf32-littleriscv) /* 32-bit little endian */

MEMORY
{
    SYS (rwx)         : ORIGIN = 0x0,          LENGTH = 16K
    TRAP (rx)         : ORIGIN = 0x00002000,   LENGTH = 1K
    INSTR (rwx)       : ORIGIN = 0x00040000,   LENGTH = 256K
}

SECTIONS
{

    /* Processor reset code needs to be here. */
    .text.boot :
    {
        *(.text.boot)
    }> SYS

    /* Trap Handler */
    .text.trap :
    {
        KEEP(*(.text.trap))
    }> TRAP

    /* Now everything in application memory. */
    .text :
    {
        *(.text)    
    }> INSTR

    .bss : 
    {
        __bss_start = .;
        *(.bss)    
        __bss_end  = .;
    }> INSTR

    .data : 
    {
        *(.data)    
    }> INSTR

    .rodata : 
    {
        *(.rodata)    
    }> INSTR

    .heap :
    {
        __heap_start = .;
        . += 32K;
        __heap_end   = .;
    }> INSTR

}

