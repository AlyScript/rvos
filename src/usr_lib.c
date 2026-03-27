#include <usr_lib.h>
#include <syscalls.h>

long syscall(long num, long arg0, long arg1, long arg2) {
    register long a0 asm("a0") = arg0;
    register long a1 asm("a1") = arg1;
    register long a2 asm("a2") = arg2;
    register long a7 asm("a7") = num; // a7 conventionally holds the syscall number

    asm volatile(
        "ecall"
        : "+r"(a0)
        : "r"(a1), "r"(a2), "r"(a7)
        : "memory"
    );
    return a0;
}

void putchar(char c) {
  register int a0 asm("a0") = (int)c;
  register int a7 asm("a7") = SYS_PUTCHAR;

  asm volatile("ecall" : "+r"(a0) : "r"(a0), "r"(a7) : "memory");
}

long getpid(void) {
    return syscall(SYS_GETPID, 0, 0, 0);
}

void yield(void) {
    syscall(SYS_SCHED_YIELD, 0, 0, 0);
}

