#include "usr_lib.h"
#include "syscalls.h"

void putchar(char c) {
  register int a0 asm("a0") = (int)c;
  register int a7 asm("a7") = SYS_PUTCHAR;

  asm volatile("ecall" : "+r"(a0) : "r"(a0), "r"(a7) : "memory");
}
