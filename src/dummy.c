#include <syscalls.h>
#include <usr_lib.h>

/* The entry point for our user process */
void _ustart(void) {
    while (1) {
        long my_pid = getpid();
        
        yield();
    }
}
