#include <syscalls.h>
#include <stdint.h>
#include <usr_lib.h>

void printf(char *fmt, ...);
void print_int(uint64_t n);

/* The entry point for user process */
/* All that's being done for now is logging a heartbeat to UART. */
__attribute__((section(".text.entry")))
void _ustart(void) {
    int pid = (int)syscall(SYS_GETPID, 0, 0, 0);
    printf("[P%d] Echo Server Started. Type something!\n", pid);

    // while(1) {
    //     char c = getchar();
    //     
    //     printf("P%d heard: %c\n", pid, c);
    //     
    //     if (c == 'q') {
    //         printf("[P%d] Quitting...\n", pid);
    //         exit(0);
    //     }
    // }
}
