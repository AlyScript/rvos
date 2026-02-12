#include <stdint.h>

#define NO_FRAMES 1048576
#define PAGE_SIZE_BYTES 4096

int populate_page_list(uint64_t startAddr);
void *alloc_page();
