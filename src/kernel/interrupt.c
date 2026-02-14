#include <interrupt.h>

void __attribute__((section(".text.trap"), weak)) handle_s_soft_int(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_m_soft_int(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_s_timer_int(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_m_timer_int(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_s_ext_int(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_m_ext_int(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_counter_ovf(pt_regs *regs) { handle_reserved(regs); }

__attribute__((section(".data.sys")))
const handler_t __itable[] = {
    [0]  = handle_reserved,
    [1]  = handle_s_soft_int,
    [2]  = handle_reserved,
    [3]  = handle_m_soft_int,
    [4]  = handle_reserved,
    [5]  = handle_s_timer_int,
    [6]  = handle_reserved,
    [7]  = handle_m_timer_int,
    [8]  = handle_reserved,
    [9]  = handle_s_ext_int,
    [10] = handle_reserved,
    [11] = handle_m_ext_int,
    [12] = handle_reserved,
    [13] = handle_counter_ovf
};
