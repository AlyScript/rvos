#include <page.h>


extern uint64_t _start;

uint64_t MEM_LIMIT = 5ULL * GB; /* 3GB */
pf *free_list_head = 0;

__attribute__((aligned(4096))) uint64_t __root_pte[512] = {0};

static inline void flush_tlb_global() {
  // sfence.vma rs1, rs2
  // rs1 = 0: flush all addresses
  // rs2 = 0: flush all address space identifiers (ASIDs)
  asm volatile("sfence.vma zero, zero" : : : "memory");
}

void *memset(void *dest, const int val, size_t n) {
  for (size_t i = 0; i < n; i++) {
    ((char *)dest)[i] = val;
  }
}

/* SATP: This register holds the physical page number (PPN) of the root page table, i.e., its supervisor physical
 * address divided by 4 KiB */
uint64_t create_pte(uint64_t addr, unsigned char flags) {
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
/* IMPORTANT: The pointers in the free list are virtual addresses with VIRT_OFFSET added to the
   underlying address. __pa(address) has to be used to return the actual address of the frame. */
void *alloc_page() {
  pf *node = free_list_head;
  free_list_head = node->next;
  return (void *)__pa(node);
}

/* Free a 4K aligned page frame. */
/* The pointer to the page is a physical address
   so any operations on it (i.e. clearing it) require __va(page)! */
int free_page(void *page) {
  if (((uint64_t)page) & 0xFFF) {
    // Misaligned address.
    return -1;
  }

  pf *node = (pf *)__va(page);
  node->next = free_list_head;
  free_list_head = node;
  return 0;
}

/* Populate free list and delete identity mapping. 
   `mem_start` is the *physical* address that corresponds to the end of the kernel's GiB.
 */
void pm_init(uint64_t mem_start, uint64_t mem_end) {
  while (mem_start & 0xFFF)
    ++mem_start; /* Ensure 4K aligned */
  for (uint64_t addr = mem_start; addr < mem_end; addr += 4096) {
    free_page((void *)addr);
  }

  /* Delete identity mapping */
  uint64_t id_index = (PHY_BASE >> 30) & 0x1FF;
  __root_pte[id_index] = 0;
}

/* Create an identity mapping for the kernel. We're mapping 1GiB of Kernel RAM so we just do this as a direct gigapage
 * mapping. */
/* Also create a higher half mapping. */
/* Virtual addresses are 39 bits, so need to shift right by 30 bits and mask the upper 9 bits (0x1FF) */
void page_init() {
  /* Identity mapping */
  uint64_t id_index = (PHY_BASE >> 30) & 0x1FF;
  __root_pte[id_index] = create_pte(PHY_BASE, PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D);

  /* Higher half mapping */
  /* The entire address space is mapped, not just the kernel 
     because we need to be able to access any possible address 
     by just calculating the offset. */
  uint64_t high_vaddr = VIRT_OFFSET + PHY_BASE;
  uint64_t high_index = (high_vaddr >> 30) & 0x1FF;
  for (size_t i = 0, offset = 0; i < 4; ++i, offset += GB) {
     __root_pte[high_index + i] = create_pte(PHY_BASE + offset, PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D);
  }
}

/* Create a mapping for a virtual address */
void map_vaddr(uint64_t vaddr, uint64_t paddr, unsigned char flags) {
  /* Level 2 */
  uint64_t root_index = vaddr >> 30;
  flags |= 0x1; // All valid from here.
  if (!((__root_pte[root_index] & 1)) || ((__root_pte[root_index] & 1) && (__root_pte[root_index] & ~PTE_NODE))) {
    uint64_t frame = (uint64_t)alloc_page();
    memset((void *)frame, 0, 4096);
    uint64_t entry = create_pte(frame, (!PTE_U & !PTE_A & !PTE_D) | PTE_V);
    __root_pte[root_index] = entry;
    flush_tlb_global();
  }

  /* Level 1 */
  uint64_t *level_1_table = pte_to_ptr(__root_pte[root_index]);
  uint64_t level_one_index = (vaddr >> 21) & 0x1FF;
  if (!(level_1_table[level_one_index] & 1) ||
      ((level_1_table[level_one_index] & 1) && (level_1_table[level_one_index] & ~PTE_NODE))) {
    uint64_t frame = (uint64_t)alloc_page();
    memset((void *)frame, 0, 4096);
    uint64_t entry = create_pte(frame, (!PTE_U & !PTE_A & !PTE_D) | PTE_V);
    level_1_table[level_one_index] = entry;
    flush_tlb_global();
  }

  /* Final Level */
  uint64_t *leaf_table = pte_to_ptr(level_1_table[level_one_index]);
  uint64_t leaf_index = (vaddr >> 12) & 0x1FF; /* Indexes are 9 bits */

  uint64_t entry = create_pte(paddr & ~0xFFF, flags | PTE_U | PTE_V | PTE_A | PTE_W | PTE_D);

  leaf_table[leaf_index] = entry;

  flush_tlb_global();
}

// Source - https://stackoverflow.com/a/66809749
// Posted by selbie, modified by community. See post 'Timeline' for change history
// Retrieved 2026-02-12, License - CC BY-SA 4.0
void *memcpy(void *dest, const void *src, size_t n) {
  for (size_t i = 0; i < n; i++) {
    ((char *)dest)[i] = ((char *)src)[i];
  }
}
