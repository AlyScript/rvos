OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
ENTRY(_start)
PROVIDE( __global_pointer$ = . + (0x20000000) );

MEMORY
{
  STAR (rwx) : ORIGIN = 0x000,   LENGTH = 0x50
  SYSINSTR (rwx) : ORIGIN = 0x100,  LENGTH = 0x4000
  DATA (rwx) : ORIGIN = 0x350,      LENGTH = 0x100
  INST (rwx) : ORIGIN = 0x450,      LENGTH = 0x1000   
}

SECTIONS
{
 
  .text.startup :
  {  

    FILL (0x10101010) 
  } > STAR 

  .text : 
  {
    FILL (0x10101010) 

  } > SYSINSTR
     
 
}
