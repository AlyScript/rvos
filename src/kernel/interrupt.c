// .section .data.sys
// .global __itable
// __itable:
//     .dword handle_reserved           /* 0  */
//     .dword handle_s_soft_int         /* 1  */
//     .dword handle_reserved           /* 2  */
//     .dword handle_m_soft_int         /* 3  */
//     .dword handle_reserved           /* 4  */
//     .dword handle_s_timer_int        /* 5  */
//     .dword handle_reserved           /* 6  */
//     .dword handle_m_timer_int        /* 7  */
//     .dword handle_reserved           /* 8  */
//     .dword handle_s_ext_int          /* 9  */
//     .dword handle_reserved           /* 10 */
//     .dword handle_m_ext_int          /* 11 */
//     .dword handle_reserved           /* 12 */
//     .dword handle_counter_ovf        /* 13 */

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
