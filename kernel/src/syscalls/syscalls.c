/* syscalls.c ---------------------------------------------------------- */
#include <errno.h>
#include <sys/types.h>
#include <unistd.h>

/* Defined in the linker script */
extern char *__heap_start;
extern char *__heap_end;

static char *heap_ptr;

#define SERIAL_INTERFACE_ADDR 0x00010500
#define SYS_WRITE 0

static inline void uart_putc(char c) {
  uint8_t *tx = (uint8_t *)SERIAL_INTERFACE_ADDR;
  *tx = (uint8_t)c;
}

/* Write the byte, then check if it was received before sending another. */
int write_to_uart(const void *buf, size_t count) {
  const char *p = buf;
  for (size_t i = 0; i < count; ++i) {
    uart_putc((char)p[i]);
  }
  return count;
}

/* Memory allocation --------------------------------------------------- */
void *_sbrk(int incr) {
  if (heap_ptr == NULL) {
    heap_ptr = __heap_start;
  }

  char *prev = heap_ptr;
  heap_ptr += incr;
  return prev;
}

/* I/O ----------------------------------------------------------------- */
int _close(int fd) {
  errno = ENOSYS;
  return -1;
}

int _lseek(int fd, off_t offset, int whence) {
  errno = ENOSYS;
  return -1;
}

int _read(int fd, void *buf, size_t count) {
  errno = ENOSYS;
  return -1;
}

/* https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html */
int _write(int fd, const void *buf, size_t count) {
  if (!buf) {
    errno = EINVAL;
    return -1;
  }

  if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
    uint32_t ret_val;
    __asm__ volatile(
        // 1. Set Arguments (a0-a2)
        "mv a0, %2\n" // Move fd (File Descriptor) to a0
        "mv a1, %3\n" // Move buf (Buffer address) to a1
        "mv a2, %4\n" // Move count (Byte count) to a2

        // 2. Set Syscall Number (a7)
        "li a7, %1\n" // Load Immediate: Set system call number (index) into a7

        // 3. Execute the trap
        "ecall\n" // Trigger the trap into kernel mode

        // 4. Read Return Value
        "mv %0, a0\n" // Move the return value from a0 back to C variable (ret_val)

        // Input/Output/Clobber List:
        : "=r"(ret_val)                    // Output: %0 = ret_val (get value from a0)
        : "i"(SYS_WRITE),                  // Input: %1 = SYS_WRITE (immediate)
          "r"(fd),                         // Input: %2 = fd (register)
          "r"(buf),                        // Input: %3 = buf (register)
          "r"(count)                       // Input: %4 = count (register)
        : "a0", "a1", "a2", "a7", "memory" // Clobber: Tell the compiler we modified these registers
    );

    if (ret_val < 0) {
      errno = (uint32_t)-ret_val;
    }

    return (int)ret_val;
  }

  return -1;
}

/* Miscellaneous ------------------------------------------------------- */
int _fstat(int fd, struct stat *st) {
  errno = ENOSYS;
  return -1;
}

int _isatty(int fd) {
  errno = ENOSYS;
  return 0; /* false */
}
