#include <page.h>

char page_list[NO_FRAMES] __attribute__((section(".data.sys")));
uint64_t *page_frames[NO_FRAMES] __attribute__((section(".data.sys")));

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
  for (unsigned int i = 0; i < sizeof(page_frames); ++i) {
    if (page_list[i] == 0) {
      return page_frames[i];
    }
  }
  return nullptr;
}
