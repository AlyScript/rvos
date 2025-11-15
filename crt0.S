#include "newlib.h"

#=========================================================================
# crt0.S : Entry point for RISC-V user programs
#=========================================================================

.equ STACK_START, 0x8000

  .text
  .global _start
  .type   _start, @function

_start:
    li sp, STACK_START    

    call main

    .size  _start, .-_start
