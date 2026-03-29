#include <syscalls.h>
#include <stdint.h>
#include <usr_lib.h>

/* The entry point for user process */
/* All that's being done for now is logging a heartbeat to UART. */

void _ustart(void) {
  while(1) {
          int pid = (int)syscall(SYS_GETPID, 0, 0, 0); 

          uint64_t current_time;
          asm volatile("csrr %0, time" : "=r"(current_time));
          uint64_t sec = current_time / 10000000;
          uint64_t ms  = (current_time % 10000000) / 10000;

          printf("[P%d] Uptime: %u.%u seconds\n", pid, sec, ms);

          for(volatile int i = 0; i < 500000; i++);
      }
}
