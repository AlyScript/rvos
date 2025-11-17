#include <stddef.h>
#include <stdint.h>

__attribute__((section(".trap.text")))

#define SERIAL_INTERFACE_ADDR 0x00010500
uint32_t sys_write(uint32_t fd, uint32_t buf, uint32_t count, uint32_t a3, uint32_t a4, uint32_t a5) {
  const char *p = (const char *)(uintptr_t)buf;
  uint8_t *tx = (uint8_t *)SERIAL_INTERFACE_ADDR;
  for (size_t i = 0; i < count; ++i) {
    *tx = (uint8_t)p[i];
  }

  return (uint32_t)count;
}
