#pragma once

#include <stdint.h>
#include <trap.h>  

typedef enum { 
    PROC_UNUSED, 
    PROC_READY, 
    PROC_RUNNING 
} proc_state_t;

typedef struct {
    int pid;                
    proc_state_t state;     
    uint64_t satp;         
    pt_regs *trapframe;   
} process_t;

#define MAX_PROCESSES 4
#define TIMER_INTERVAL 1000000 

extern process_t process_table[MAX_PROCESSES];
extern process_t *current_process;
void timer_init(void);
void set_next_timer_interrupt(void);
pt_regs* schedule(pt_regs *interrupted_regs);
void spawn_payload_process(void);
pt_regs* pexit(pt_regs *regs);
