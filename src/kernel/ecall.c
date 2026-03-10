#include <ecall.h>
#include <page.h>
#include <sbi.h>

static inline void w_sepc(uint64_t val) {
  asm volatile("csrw sepc, %0" : : "r"(val));
}

static inline uint64_t r_sepc() {
  uint64_t x;
  asm volatile("csrr %0, sepc" : "=r"(x));
  return x;
}

static inline uint64_t r_stval() {
  uint64_t x;
  asm volatile("csrr %0, stval" : "=r"(x));
  return x;
}

static inline uint64_t r_sstatus() {
  uint64_t x;
  asm volatile("csrr %0, sstatus" : "=r"(x));
  return x;
}


void handle_insn_misaligned(pt_regs *regs) { handle_reserved(regs); }
void handle_insn_fault(pt_regs *regs) { handle_reserved(regs); }
void handle_illegal_insn(pt_regs *regs) { handle_reserved(regs); }
void handle_breakpoint(pt_regs *regs) { handle_reserved(regs); }
void handle_load_misaligned(pt_regs *regs) { handle_reserved(regs); }
void handle_load_fault(pt_regs *regs) { handle_reserved(regs); }
void handle_store_misaligned(pt_regs *regs) { handle_reserved(regs); }
void handle_store_fault(pt_regs *regs) { handle_reserved(regs); }

void handle_ecall_u(pt_regs *regs) { 
    handle_syscall(regs);
    uint64_t sepc = r_sepc();
    w_sepc(sepc + 4);
}

void handle_ecall_s(pt_regs *regs) { handle_reserved(regs); }
void handle_ecall_m(pt_regs *regs) { handle_reserved(regs); }

/* Page fault handlers. There are a number of cases to handle here. */
/* If a fault occurred because a page was invalid, i.e. V == 0 and ONLY because of this, then we need to allocate one.
 */
/* In any case, the first thing to do is check the address that caused the fault. */
/* From there, we can identify the PTE that caused the trap and then handle the fault accordingly. */
void handle_insn_page_fault(pt_regs *regs) {
  uint64_t sepc = r_sepc();
  uint64_t stval = r_stval();
  uint64_t sstatus = r_sstatus();
  unsigned char spp = (sstatus >> 8) & 1; // 0 if previous privilege was user, 1 otherwise
  spp ^= 1;                               // Can check if spp < U bit in the PTE to see if not allowed

  // First check if due to being invalid
  // uint64_t entry = __root_pte[(sepc >> 30) & 0x1FF];
  map_vaddr(stval, sepc, PTE_U | PTE_V | PTE_R | PTE_X | (spp << 4));
  // flush_tlb_global();
}

void handle_load_page_fault(pt_regs *regs) {
    handle_insn_page_fault(regs);
}

void handle_store_page_fault(pt_regs *regs) {
    handle_insn_page_fault(regs);
}

void handle_double_trap(pt_regs *regs) { handle_reserved(regs); }
void handle_sw_check(pt_regs *regs) { handle_reserved(regs); }
void handle_hw_error(pt_regs *regs) { handle_reserved(regs); }

const handler_t __etable[] = {[0] = handle_insn_misaligned,   [1] = handle_insn_fault,       [2] = handle_illegal_insn,
                              [3] = handle_breakpoint,        [4] = handle_load_misaligned,  [5] = handle_load_fault,
                              [6] = handle_store_misaligned,  [7] = handle_store_fault,      [8] = handle_ecall_u,
                              [9] = handle_ecall_s,           [10] = handle_reserved,        [11] = handle_ecall_m,
                              [12] = handle_insn_page_fault,  [13] = handle_load_page_fault, [14] = handle_reserved,
                              [15] = handle_store_page_fault, [16] = handle_double_trap,     [17] = handle_reserved,
                              [18] = handle_sw_check,         [19] = handle_hw_error};
