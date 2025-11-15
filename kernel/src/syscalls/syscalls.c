/* syscalls.c ---------------------------------------------------------- */
#include <errno.h>
#include <sys/types.h>
#include <unistd.h>

/* Defined in the linker script */
extern char *__heap_start;
extern char *__heap_end;

static char *heap_ptr;

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

int _write(int fd, const void *buf, size_t count) { return count; }

/* Miscellaneous ------------------------------------------------------- */
int _fstat(int fd, struct stat *st) {
  errno = ENOSYS;
  return -1;
}

int _isatty(int fd) {
  errno = ENOSYS;
  return 0; /* false */
}
