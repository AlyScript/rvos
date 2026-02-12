#include <page.h>

typedef struct {
    uint64_t N;    // 1 bit
    uint64_t PBMT; // 2 bits
    // RESERVED         // 7 bits
    uint64_t PPN2;       // 26 Bits
    uint64_t PPN1;       // 9 Bits
    uint64_t PPN0;       // 9 bits
    uint64_t RSW;  // 3 bits

    uint64_t D;    // 1 bit everything beneath here
    uint64_t A;
    uint64_t G;
    uint64_t U;
    uint64_t X;
    uint64_t W;
    uint64_t R;
    uint64_t V;
}_PTE ;

/* Physical Memory */
char page_list[NO_FRAMES] __attribute__((section(".data.sys")));
uint64_t *page_frames[NO_FRAMES] __attribute__((section(".data.sys")));

/* Virtual Memory */
pte_t root_level_table[PAGE_SIZE_BYTES / 8] __attribute__((aligned(PAGE_SIZE_BYTES), section(".data.sys")));

const uint64_t RWX_BITMASK = 0xFFFFFFFFFFFFFFF1;
// const uint64_t VALID_BITMASK = 0xFFFFFFFFFFFFFFFE;

__attribute__((section(".text.sys"))) pte_t create_pt_entry(_PTE pte) {
    pte_t entry = 0;
    entry |= (pte.N << 63);
    entry |= (pte.PBMT << 62);
    entry |= (pte.PPN2 << 53);
    entry |= (pte.PPN1 << 27);
    entry |= (pte.PPN0 << 18);
    entry |= (pte.RSW << 9);
    entry |= (pte.D << 7);
    entry |= (pte.A << 6);
    entry |= (pte.G << 5);
    entry |= (pte.U << 4);
    entry |= (pte.X << 3);
    entry |= (pte.W << 2);
    entry |= (pte.R << 1);
    entry |= (pte.V);
    return entry;
}

void populate_page_tables() {
    uint64_t prev = 0;
    uint64_t addr = 0;
    _PTE entry; // Make sure to zero everything
    for (uint64_t i = 0; i < 512; ++i) {
        entry.PPN2 = addr;
        root_level_table[i] = create_pt_entry(entry);
        addr += 4096;
        for (uint64_t  j = 0; j < 512; ++j) {
            entry.PPN1 = addr;
            pte_t *second_level_table = (pte_t *)root_level_table[i];
            second_level_table[j] = create_pt_entry(entry);
            addr += 4096;
            for (uint64_t k = 0; k < 512; ++k) {
                entry.PPN0 = addr;
                pte_t *leaf_table = (pte_t *)second_level_table[j];
                leaf_table[k] = create_pt_entry(entry);
                addr += 4096;
            }
        }
    }
}

/* Create a page table entry for a physical frame and return it. */
/* Assume no entry exists for this frame already. */
// __attribute__((section(".text.sys"))) pte_t *create_pte(uint64_t phys_frame_no) { 
//     for (unsigned int i = 0; i < 512; ++i) {
//         if (!(root_level_table[i] & 1)) {
//             memset(root_level_table[i], 0, PAGE_SIZE_BYTES);
//         }
//         for (unsigned int j = 0; j < 512; ++j) {
//             ptr_t *second_level_table = root_level_table[i];
//             if (!(second_level_table[j] & 1)) {
//                 memset(second_level_table[j], 0, PAGE_SIZE_BYTES);
//             }
//             for (unsigned int k = 0; k < 512; ++k) {
//                 ptr_t *leaf_table = second_level_table[j];
//                 if (!(leaf_table[k] & 1)) {
//
//                     // Found a match. Now we need to:
//                     // 1. Create a PTE in the root level table that points to the second level table.
//                     // 2. Create a PTE in the second level table that points to the leaf table (this one).
//                     // 3. Create a PTE in the leaf table that points to the physical frame we have just allocated.
//
//                     create_pte(root_level_table[i], FLAGS); // Entry that has PPN[2] set to the second_level_table
//                     create_pte(second_level_table[j], FLAGS); // Entry that has PPN[1] set to the leaf_table
//                     create_pte(leaf_table[k], FLAGS);       // Entry that has PPN[0] set to the physical page frame
//
//                     second_level_table[j] = leaf_table;// Point to the leaf table
//                     leaf_table[k] = phys_frame_no; // Found a match, so point it.
//                     return;
//                 }
//             }
//         }
//     }
// }

/*



*/

/* Walk the virtual page table. If an entry */
__attribute__((section(".text.sys"))) pte_t *pagedir_walk() {

}

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


// Source - https://stackoverflow.com/a/66809749
// Posted by selbie, modified by community. See post 'Timeline' for change history
// Retrieved 2026-02-12, License - CC BY-SA 4.0
void *memcpy(void *dest, const void *src, size_t n)
{
    for (size_t i = 0; i < n; i++)
    {
        ((char*)dest)[i] = ((char*)src)[i];
    }
}
