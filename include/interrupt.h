#pragma once

#include <trap.h>

const handler_t __itable[];

/* External Interrupt Handler Declarations */
/* All handlers accept a pointer to the pt_regs struct built in assembly */

void handle_s_soft_int(pt_regs *regs);    /* Supervisor software interrupt */
void handle_m_soft_int(pt_regs *regs);    /* Machine software interrupt    */

void handle_s_timer_int(pt_regs *regs);   /* Supervisor timer interrupt    */
void handle_m_timer_int(pt_regs *regs);   /* Machine timer interrupt       */

void handle_s_ext_int(pt_regs *regs);     /* Supervisor external interrupt */
void handle_m_ext_int(pt_regs *regs);     /* Machine external interrupt    */

void handle_counter_ovf(pt_regs *regs);   /* Counter-overflow interrupt    */
