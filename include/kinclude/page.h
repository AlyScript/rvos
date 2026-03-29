#pragma once

#include <stdint.h>

#define PTE_V           0x1
#define PTE_A           (1 << 6)
#define PTE_D           (1 << 7)
#define PTE_R           0x2
#define PTE_W           0x4
#define PTE_X           0x8
#define PTE_U           0x10
#define PTE_NODE        ~0xE

#define GB              (1ULL << 30)

#define VIRT_OFFSET     0xFFFFFFC000000000ULL
#define PHY_BASE        0x0000000080000000ULL

#define pte_to_ptr(pte) ((uint64_t *)__va((((pte) >> 10) & 0xFFFFFFFFFFFULL) << 12))

/* Virtual to physical address and vice versa */
#define __va(pa) ((void *)((uint64_t)(pa) + VIRT_OFFSET))
#define __pa(va) ((uint64_t)(va) - VIRT_OFFSET)

extern uint64_t MEM_LIMIT; /* 5GB */

typedef struct {
  uint64_t ppn;
  unsigned char flags; // D A G U X W R V
} pte;

typedef struct pf {
  struct pf *next;
} pf;

extern uint64_t __root_pte[512];
extern pf *free_list_head;

// uint64_t* pte_to_ptr(uint64_t pte);
static inline void flush_tlb_global();
void *alloc_page();
int free_page(void *page);
void pm_init(uint64_t mem_start, uint64_t mem_end);
// void init_page_allocator();
void page_init();
void map_vaddr(uint64_t *root_table, uint64_t vaddr, uint64_t paddr, unsigned char flags);
uint64_t create_pte(uint64_t addr, unsigned char flags);
void *memset(void *dest, const int val, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
