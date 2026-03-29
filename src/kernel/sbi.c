#include <sbi.h>
#include <stdint.h>
#include <stdarg.h>

/* Simple wrapper for talking to OpenSBI */
struct sbiret sbi_call(long ext, long fid, long arg0, long arg1, long arg2, long arg3, long arg4, long arg5) {
    register long a0 asm("a0") = arg0;
    register long a1 asm("a1") = arg1;
    register long a2 asm("a2") = arg2;
    register long a3 asm("a3") = arg3;
    register long a4 asm("a4") = arg4;
    register long a5 asm("a5") = arg5;
    register long a6 asm("a6") = fid;
    register long a7 asm("a7") = ext;

    asm volatile(
        "ecall"
        : "+r" (a0), "+r" (a1)
        : "r" (a2), "r" (a3), "r" (a4), "r" (a5), "r" (a6), "r" (a7)
        : "memory"
    );

    struct sbiret ret;
    ret.error = a0;
    ret.value = a1;
    return ret;
}

void sbi_putchar(const char c) {
  sbi_call(1, 0, c, 0, 0, 0, 0, 0);
}

void sbi_set_timer(uint64_t stime_value) {
  sbi_call(0x54494D45, 0, stime_value, 0, 0, 0, 0, 0);
}

static void sbi_puts(const char *s) {
    while (*s) {
        sbi_putchar(*s++);
    }
}

static void sbi_print_uint(uint64_t n, int base) {
    char buf[32];
    int i = 30;
    buf[31] = '\0';
    
    if (n == 0) {
        sbi_putchar('0');
        return;
    }
    
    while (n > 0) {
        int rem = n % base;
        buf[i--] = (rem < 10) ? (rem + '0') : (rem - 10 + 'a');
        n /= base;
    }
    sbi_puts(&buf[i + 1]);
}

static void sbi_print_int(int64_t n) {
    if (n < 0) {
        sbi_putchar('-');
        n = -n;
    }
    sbi_print_uint((uint64_t)n, 10);
}

void sbi_printf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    for (const char *p = fmt; *p != '\0'; p++) {
        if (*p != '%') {
            sbi_putchar(*p);
            continue;
        }
        switch (*++p) {
            case 'c': sbi_putchar((char)va_arg(ap, int)); break;
            case 's': sbi_puts(va_arg(ap, char *)); break;
            case 'd': sbi_print_int(va_arg(ap, int64_t)); break;
            case 'u': sbi_print_uint(va_arg(ap, uint64_t), 10); break;
            case 'x': 
                sbi_puts("0x");
                sbi_print_uint(va_arg(ap, uint64_t), 16); 
                break;
            case '%': sbi_putchar('%'); break;
            default:
                sbi_putchar('%');
                sbi_putchar(*p);
                break;
        }
    }
    va_end(ap);
}
