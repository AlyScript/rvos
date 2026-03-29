#include <syscalls.h>
#include <stdint.h>
#include <usr_lib.h>

/* The entry point for user process */
/* All that's being done for now is logging a heartbeat to UART. */
void _ustart(void) {
    int pid = (int)syscall(SYS_GETPID, 0, 0, 0); 

    for(int loops = 0; loops < 50; loops++) {
        uint64_t current_time;
        asm volatile("csrr %0, time" : "=r"(current_time));
        uint64_t sec = current_time / 10000000;
        uint64_t ms  = (current_time % 10000000) / 10000;

        printf("[P%d] Loop %d/50 | Uptime: %u.%u\n", pid, loops + 1, sec, ms);

        for(volatile int i = 0; i < 5000000; i++); 
    }

    printf("[P%d] Exiting gracefully.\n", pid);
    exit(0);
}
