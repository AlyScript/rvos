#include <page.h>

extern uint64_t _start;

typedef struct {
  uint64_t ppn;
  unsigned char flags; // D A G U X W R V
} pte;

uint64_t __root_pte[512];

/* Physical Memory */
unsigned char page_list[NO_FRAMES] __attribute__((section(".data.sys")));
// uint64_t *page_frames[NO_FRAMES] __attribute__((section(".data.sys")));

/* SATP: This register holds the physical page number (PPN) of the root page table, i.e., its supervisor physical
 * address divided by 4 KiB */
uint64_t create_pte(uint64_t addr, unsigned char flags) {
  if (addr & 0x7) {
    // Misaligned
    return 0;
  }
  uint64_t ret = flags;
  addr >>= 12;
  ret |= (addr << 10);
  return ret;
}

/* Create an identity mapping for the kernel. We're mapping 1GiB of Kernel RAM so we just do this as a direct gigapage
 * mapping. */
__attribute__((section(".text.sys"))) void page_init() {
  uint64_t kernel_addr = (uint64_t)(&_start);
  uint64_t gigapage_base = kernel_addr & ~0x3FFFFFFF; /* Must be gigabyte aligned, so zero out bottom 30 bits */
  uint64_t entry = create_pte(gigapage_base, 0xF);    /* Flags: XWRV. TODO: come back and change clear W for instructions and X for data. */
  __root_pte[kernel_addr >> 30] = entry;              /* MMU will take the upper 9 bits of the 39 bit address and use it as an index into the root table */
                                                      /* The PTE for our identity mapping needs to be there when it does. */
  page_list[kernel_addr >> 30] = 1                    /* Mark this page as in use */
}

/* Finds a free page frame and returns a pointer to the beginning of it. */
__attribute__((section(".text.sys"))) void *alloc_page() {
  for (unsigned int i = 0; i < sizeof(page_frames) / sizeof(uint64_t *); ++i) {
    if (page_list[i] == 0) {
      return page_frames[i];
    }
  }
  return nullptr;
}

// Source - https://stackoverflow.com/a/66809749
// Posted by selbie, modified by community. See post 'Timeline' for change history
// Retrieved 2026-02-12, License - CC BY-SA 4.0
void *memcpy(void *dest, const void *src, size_t n) {
  for (size_t i = 0; i < n; i++) {
    ((char *)dest)[i] = ((char *)src)[i];
  }
}
