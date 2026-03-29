#pragma once

#include <trap.h>

extern const handler_t __etable[];

pt_regs* handle_reserved(pt_regs *regs);
pt_regs* handle_insn_misaligned(pt_regs *regs);
pt_regs* handle_insn_fault(pt_regs *regs);
pt_regs* handle_illegal_insn(pt_regs *regs);
pt_regs* handle_breakpoint(pt_regs *regs);
pt_regs* handle_load_misaligned(pt_regs *regs);
pt_regs* handle_load_fault(pt_regs *regs);
pt_regs* handle_store_misaligned(pt_regs *regs);
pt_regs* handle_store_fault(pt_regs *regs);
pt_regs* handle_ecall_u(pt_regs *regs);
pt_regs* handle_ecall_s(pt_regs *regs);
pt_regs* handle_ecall_m(pt_regs *regs);
pt_regs* handle_insn_page_fault(pt_regs *regs);
pt_regs* handle_load_page_fault(pt_regs *regs);
pt_regs* handle_store_page_fault(pt_regs *regs);
pt_regs* handle_double_trap(pt_regs *regs);
pt_regs* handle_sw_check(pt_regs *regs);
pt_regs* handle_hw_error(pt_regs *regs);
