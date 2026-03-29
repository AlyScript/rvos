#include <proc.h>
#include <sbi.h>
#include <syscalls.h>
#include <stdint.h>
#include <trap.h>

void handle_syscall(pt_regs *regs) {
  uint64_t syscall = regs->a7;

  switch (syscall) {
  case SYS_PUTCHAR:
    sbi_putchar((char)regs->a0);
    regs->a0 = 0; /* Return value in a0 */
    break;
  case SYS_GETPID:
    regs->a0 = current_process->pid;
    break;
  }
}
