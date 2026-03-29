#pragma once

#include <trap.h>
#include <ecall.h>

extern const handler_t __itable[];

/* External Interrupt Handler Declarations */
/* All handlers accept a pointer to the pt_regs struct built in assembly */

pt_regs* handle_s_soft_int(pt_regs *regs);    /* Supervisor software interrupt */
pt_regs* handle_m_soft_int(pt_regs *regs);    /* Machine software interrupt    */

pt_regs* handle_s_timer_int(pt_regs *regs);   /* Supervisor timer interrupt    */
pt_regs* handle_m_timer_int(pt_regs *regs);   /* Machine timer interrupt       */

pt_regs* handle_s_ext_int(pt_regs *regs);     /* Supervisor external interrupt */
pt_regs* handle_m_ext_int(pt_regs *regs);     /* Machine external interrupt    */

pt_regs* handle_counter_ovf(pt_regs *regs);   /* Counter-overflow interrupt    */
