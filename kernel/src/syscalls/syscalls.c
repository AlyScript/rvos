/* syscalls.c ---------------------------------------------------------- */
#include <errno.h>
#include <sys/types.h>
#include <unistd.h>

/* Defined in the linker script */
extern char *__heap_start;
extern char *__heap_end;

static char *heap_ptr;

#define SERIAL_INTERFACE_ADDR 0x00010500

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

int _write(int fd, const void *buf, size_t count) {
  if (!buf) {
    errno = EINVAL;
    return -1;
  }

  if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
    return write_to_uart(buf, count);
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
