#include "sbi.h"
#include "syscalls.h"
#include <stdint.h>

__attribute__((section(".text.trap"))) void handle_syscall(uint64_t *regs) {
  uint64_t syscall = regs[17];

  switch (syscall) {
  case SYS_PUTCHAR:
    sbi_putchar((char)regs[10]);
    regs[10] = 0;
    break;
  }
}
