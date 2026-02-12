#include <page.h>

/* Physical Memory */
char page_list[NO_FRAMES] __attribute__((section(".data.sys")));
uint64_t *page_frames[NO_FRAMES] __attribute__((section(".data.sys")));

/* Virtual Memory */
uint64_t root_level_table[PAGE_SIZE_BYTES / 8] __attribute__((aligned(PAGE_SIZE_BYTES), section(".data.sys")));

const uint64_t RWX_BITMASK = 0xFFFFFFFFFFFFFFF1;
// const uint64_t VALID_BITMASK = 0xFFFFFFFFFFFFFFFE;

/* Create a page table entry for a physical frame and return a virtual address corresponding to it. */
__attribute__((section(".text.sys"))) pte_t *create_pte(uint64_t phys_frame_no) { unsigned int level = 2; }

/* Walk the virtual page table. If an entry */
__attribute__((section(".text.sys"))) void pagedir_walk() {}

__attribute__((section(".text.sys"))) void setup_page_table() {
  for (unsigned int i = 0; i < sizeof(root_level_table) / sizeof(uint64_t); ++i) {
    root_level_table[i] &= RWX_BITMASK;
  }

  // TODO: Finish this off
  // root_level_table[0]
}

/* To be called with a 4K aligned address. */
__attribute__((section(".text.sys"))) int populate_page_list(uint64_t startAddr) {
  uint64_t mask = 0x000;
  if (startAddr | mask) {
    /* Address must be 4K aligned. */
    return 1;
  }
  uint64_t p = startAddr;
  for (uint64_t i = 0; i < NO_FRAMES; ++i) {
    page_list[i] = 0;
    page_frames[i] = (uint64_t *)p;
    p += PAGE_SIZE_BYTES;
  }
  return 0;
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
