#include <usr_lib.h>
#include <syscalls.h>
#include <stdint.h>
#include <stdarg.h>

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

void puts(char *s) {
    while (*s) putchar(*s++);
}

void print_int(uint64_t n) {
    char buf[21];
    int i = 19;
    buf[20] = '\0';
    if (n == 0) {
        putchar('0');
        return;
    }
    while (n > 0) {
        buf[i--] = (n % 10) + '0';
        n /= 10;
    }
    puts(&buf[i + 1]);
}

void printf(char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    for (char *p = fmt; *p != '\0'; p++) {
        if (*p != '%') {
            putchar(*p);
            continue;
        }
        switch (*++p) {
            case 'c': putchar((char)va_arg(ap, int)); break;
            case 's': puts(va_arg(ap, char *)); break;
            case 'd':
            case 'u': print_int(va_arg(ap, uint64_t)); break;
            case '%': putchar('%'); break;
        }
    }
    va_end(ap);
}

void exit(int code) {
    syscall(SYS_EXIT, code, 0, 0);
    while(1); /* Shouldn't reach here. */
}
