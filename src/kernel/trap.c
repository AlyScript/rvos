#include <proc.h>
#include <sbi.h>
#include <syscalls.h>
#include <stdint.h>
#include <trap.h>

extern char _dummy_bin_start[];
extern char _dummy_bin_end[];

pt_regs* handle_syscall(pt_regs *regs) {
  uint64_t syscall = regs->a7;

  switch (syscall) {
  case SYS_PUTCHAR:
    sbi_putchar((char)regs->a0);
    regs->a0 = 0; /* Return value in a0 */
    return regs;
  case SYS_GETCHAR:
    regs->a0 = sbi_getchar();
    return regs;
  case SYS_GETPID:
    regs->a0 = current_process->pid;
    return regs;
  case SYS_EXIT:
    return pexit(regs);
  case SYS_SPAWN:
    regs->a0 = spawn_payload_process(_dummy_bin_start, _dummy_bin_end);
    return regs;
  case SYS_KILL:
    regs->a0 = pkill(regs->a0);
    return regs;
  case SYS_SCHED_YIELD:
    return schedule(regs);
  }
  return regs;
}
