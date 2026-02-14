// .section .data.sys
// .global __etable
// __etable:
//     .dword handle_insn_misaligned    /* 0  */
//     .dword handle_insn_fault         /* 1  */
//     .dword handle_illegal_insn       /* 2  */
//     .dword handle_breakpoint         /* 3  */
//     .dword handle_load_misaligned    /* 4  */
//     .dword handle_load_fault         /* 5  */
//     .dword handle_store_misaligned   /* 6  */
//     .dword handle_store_fault        /* 7  */
//     .dword handle_ecall_u            /* 8  */
//     .dword handle_ecall_s            /* 9  */
//     .dword handle_reserved           /* 10 */
//     .dword handle_ecall_m            /* 11 */
//     .dword handle_insn_page_fault    /* 12 */
//     .dword handle_load_page_fault    /* 13 */
//     .dword handle_reserved           /* 14 */
//     .dword handle_store_page_fault   /* 15 */
//     .dword handle_double_trap        /* 16 */
//     .dword handle_reserved           /* 17 */
//     .dword handle_sw_check           /* 18 */
//     .dword handle_hw_error           /* 19 */

#include <ecall.h>
#include <sbi.h>

void __attribute__((section(".text.trap"), weak)) handle_insn_misaligned(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_insn_fault(pt_regs *regs)      { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_illegal_insn(pt_regs *regs)    { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_breakpoint(pt_regs *regs)      { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_load_misaligned(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_load_fault(pt_regs *regs)      { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_store_misaligned(pt_regs *regs){ handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_store_fault(pt_regs *regs)     { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_ecall_u(pt_regs *regs)         { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_ecall_s(pt_regs *regs)         { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_ecall_m(pt_regs *regs)         { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_insn_page_fault(pt_regs *regs) {

}
void __attribute__((section(".text.trap"), weak)) handle_load_page_fault(pt_regs *regs) { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_store_page_fault(pt_regs *regs){ handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_double_trap(pt_regs *regs)     { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_sw_check(pt_regs *regs)        { handle_reserved(regs); }
void __attribute__((section(".text.trap"), weak)) handle_hw_error(pt_regs *regs)        { handle_reserved(regs); }

__attribute__((section(".data.sys")))
const handler_t __etable[] = {
    [0]  = handle_insn_misaligned,
    [1]  = handle_insn_fault,
    [2]  = handle_illegal_insn,
    [3]  = handle_breakpoint,
    [4]  = handle_load_misaligned,
    [5]  = handle_load_fault,
    [6]  = handle_store_misaligned,
    [7]  = handle_store_fault,
    [8]  = handle_ecall_u,
    [9]  = handle_ecall_s,
    [10] = handle_reserved,
    [11] = handle_ecall_m,
    [12] = handle_insn_page_fault,
    [13] = handle_load_page_fault,
    [14] = handle_reserved,
    [15] = handle_store_page_fault,
    [16] = handle_double_trap,
    [17] = handle_reserved,
    [18] = handle_sw_check,
    [19] = handle_hw_error
};
