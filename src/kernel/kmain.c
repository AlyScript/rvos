#include <page.h>
#include <stdint.h>

#define VIRT_OFFSET 0xFFFFFFC000000000

uint64_t bsp_hartid;
uint64_t dtb_phys_addr;
uint64_t dtb_virt_addr;

void kmain(uint64_t hartid, uint64_t dtb_addr) {
  bsp_hartid = hartid;
  dtb_phys_addr = dtb_addr;
  dtb_virt_addr = dtb_phys_addr + VIRT_OFFSET;

  // init_page_allocator();
}
