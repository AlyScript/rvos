#include <page.h>

#define pte_to_ptr(pte) ((uint64_t *)((((pte) >> 10) & 0x3FFFFFFFFFFULL) << 12)) /* Mask 44 Bits (PFN) */

extern uint64_t _start;

__attribute__((section(".data.sys"))) uint64_t MEM_LIMIT = 5ULL * GB; /* 3GB */
__attribute__((section(".data.sys"))) pf *free_list_head = 0;

__attribute__((section(".data.sys"))) uint64_t __root_pte[512] = {0};

__attribute__((section(".text.trap"))) static inline void flush_tlb_global() {
  // sfence.vma rs1, rs2
  // rs1 = 0: flush all addresses
  // rs2 = 0: flush all address space identifiers (ASIDs)
  asm volatile("sfence.vma zero, zero" : : : "memory");
}

__attribute__((section(".text.sys"))) void *memset(void *dest, const int val, size_t n) {
  for (size_t i = 0; i < n; i++) {
    ((char *)dest)[i] = val;
  }
}

/* SATP: This register holds the physical page number (PPN) of the root page table, i.e., its supervisor physical
 * address divided by 4 KiB */
uint64_t __attribute__((section(".text.sys"))) create_pte(uint64_t addr, unsigned char flags) {
  if (addr & 0xFFF) {
    // Misaligned
    return 0;
  }
  uint64_t ret = flags;
  addr >>= 12;
  ret |= (addr << 10);
  return ret;
}

/* Finds a free page frame and returns a (page aligned) pointer to the beginning of it. */
__attribute__((section(".text.sys"))) void *alloc_page() {
    pf *node = free_list_head;
    free_list_head = node->next;
    return (void *) node;
}

/* Free a 4K aligned page */
__attribute__((section(".text.sys"))) int free_page(void *page) {
    if (((uint64_t) page) & 0x7) {
        // Misaligned address.
        return -1;
    }

    pf *node = (pf *) page;
    node->next = free_list_head;
    free_list_head = node;
    return 0;
}

/* Populate free list */
__attribute__((section(".text.sys"))) void pm_init(uint64_t mem_start, uint64_t mem_end) {
    while (mem_start & 0x7) ++mem_start;                 /* Ensure 4K aligned */
    for (uint64_t addr = mem_start; addr < mem_end; addr += 4096) {
        free_page((void *) addr);
    }
}

/* Create an identity mapping for the kernel. We're mapping 1GiB of Kernel RAM so we just do this as a direct gigapage
 * mapping. */
__attribute__((section(".text.sys"))) void page_init() {
  uint64_t kernel_addr = (uint64_t)(&_start);
  uint64_t gigapage_base = kernel_addr & ~0x3FFFFFFF;    /* Must be gigabyte aligned, so zero out bottom 30 bits */

  for (int i = 0; i < 5; ++i) {
       uint64_t addr = gigapage_base + (i * GB);
       uint64_t entry = create_pte(addr, 0xF);      /* Flags: XWRV. /* Maybe come back and change clear W for instructions and X for data> */
       __root_pte[addr >> 30] = entry;                           /* MMU will take the upper 9 bits of the 39 bit address and use it as an index into the root table */
  }
                                                                        /* The PTE for our identity mapping needs to be there when it does. */

  const uint64_t MEM_START = kernel_addr + GB;
  pm_init(MEM_START, MEM_LIMIT);
}


/* Create a mapping for a virtual address */
__attribute__((section(".text.sys"))) void map_vaddr(uint64_t vaddr, uint64_t paddr, unsigned char flags) {
    uint64_t root_index = vaddr >> 30;
    flags |= 0x1; // All valid from here.
    if (!((__root_pte[root_index] & 1)) || (__root_pte[root_index] & 1) && (__root_pte[root_index] & ~PTE_NODE)) {
        uint64_t frame = (uint64_t) alloc_page();
        memset((void *) frame, 0, 4096);
        uint64_t entry = create_pte(frame, (!PTE_U & !PTE_A & !PTE_D) | PTE_V);
        __root_pte[root_index] = entry;
        flush_tlb_global();
    }
    // __root_pte[root_index] &= PTE_NODE; 

    uint64_t *level_2_table = pte_to_ptr(__root_pte[root_index]);
    uint64_t level_two_index = (vaddr >> 21) & 0x1FF;
    if (!(level_2_table[level_two_index] & 1) || ((level_2_table[level_two_index] & 1) && (level_2_table[level_two_index] & ~PTE_NODE))) {
        uint64_t frame = (uint64_t) alloc_page();
        memset((void *) frame, 0, 4096);
        uint64_t entry = create_pte(frame, (!PTE_U & !PTE_A & !PTE_D) | PTE_V);
        level_2_table[level_two_index] = entry;
        flush_tlb_global();
    }
    // level_2_table[level_two_index] &= PTE_NODE;

    /* Final Level */
    uint64_t* leaf_table = pte_to_ptr(level_2_table[level_two_index]);
    uint64_t leaf_index = (vaddr >> 12) & 0x1FF; /* Indexes are 9 bits */

    uint64_t entry = create_pte(paddr & ~0xFFF, flags | PTE_U | PTE_V | PTE_A | PTE_W | PTE_D);

    leaf_table[leaf_index] = entry;
    //
    // __root_pte[root_index] |= PTE_U;
    //
    // level_2_table[level_two_index] |= PTE_U;

    flush_tlb_global();
}

// Source - https://stackoverflow.com/a/66809749
// Posted by selbie, modified by community. See post 'Timeline' for change history
// Retrieved 2026-02-12, License - CC BY-SA 4.0
__attribute__((section(".text.sys"))) void *memcpy(void *dest, const void *src, size_t n) {
  for (size_t i = 0; i < n; i++) {
    ((char *)dest)[i] = ((char *)src)[i];
  }
}

