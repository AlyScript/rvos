#include <trap.h>

const handler_t __etable[];

void handle_insn_misaligned(pt_regs *regs);
void handle_insn_fault(pt_regs *regs);
void handle_illegal_insn(pt_regs *regs);
void handle_breakpoint(pt_regs *regs);
void handle_load_misaligned(pt_regs *regs);
void handle_load_fault(pt_regs *regs);
void handle_store_misaligned(pt_regs *regs);
void handle_store_fault(pt_regs *regs);
void handle_ecall_u(pt_regs *regs);
void handle_ecall_s(pt_regs *regs);
void handle_ecall_m(pt_regs *regs);
void handle_insn_page_fault(pt_regs *regs);
void handle_load_page_fault(pt_regs *regs);
void handle_store_page_fault(pt_regs *regs);
void handle_double_trap(pt_regs *regs);
void handle_sw_check(pt_regs *regs);
void handle_hw_error(pt_regs *regs);
