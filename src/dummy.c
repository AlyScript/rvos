#include <syscalls.h>
#include <usr_lib.h>

/* The entry point for user process */
void _ustart(void) {
    while (1) {
        long my_pid = getpid();
        putchar('a');
        yield();
    }
}
