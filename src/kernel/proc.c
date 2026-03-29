#include <proc.h>
#include <page.h>
#include <sbi.h>

extern char _dummy_bin_start[];
extern char _dummy_bin_end[];

extern void switch_to_user(pt_regs *frame);

extern uint64_t __root_pte[512]; 

#define MAX_PROCESSES 4
process_t process_table[MAX_PROCESSES];
int next_pid = 1;

process_t *current_process = 0;

#define TIMER_INTERVAL 1000000 

void set_next_timer_interrupt(void) {
    uint64_t current_time;
    
    asm volatile("csrr %0, time" : "=r"(current_time));
    
    /* Tell OpenSBI to trigger a timer interrupt at T + TIMER_INTERVAL. */
    sbi_set_timer(current_time + TIMER_INTERVAL);
}

void timer_init() {
    /* Unmask timer interrupts. */
    asm volatile("csrs sie, %0" : : "r"(1 << 5));
    
    /* Set the first alarm. */
    set_next_timer_interrupt();
}

process_t* find_free_slot() {
    for (int i = 0; i < MAX_PROCESSES; i++) {
        if (process_table[i].state == PROC_UNUSED) {
            return &process_table[i];
        }
    }
    return 0;
}

pt_regs* schedule(pt_regs *interrupted_regs) {
    /* Save the state of the outgoing process */
    if (current_process != 0 && current_process->state == PROC_RUNNING) {
        current_process->trapframe = interrupted_regs;
        current_process->state = PROC_READY;
    }

    /* Determine where to start searching in the task list. */
    int current_index = 0;
    if (current_process != 0) {
        current_index = current_process - process_table; 
    }
    
    int next_index = (current_index + 1) % MAX_PROCESSES;
    int started_at = next_index;
    int found = 0;

    /* Find next ready process */
    do {
        if (process_table[next_index].state == PROC_READY) {
            found = 1;
            break;
        }
        next_index = (next_index + 1) % MAX_PROCESSES;
    } while (next_index != started_at);

    /* If no other processes are ready we just resume the current one. */
    if (!found) {
        if (current_process != 0) {
            current_process->state = PROC_RUNNING;
            return current_process->trapframe;
        }
        // If there are absolutely no processes, return whatever interrupted us (likely kmain)
        return interrupted_regs;
    }

    /* Context Switch */
    current_process = &process_table[next_index];
    current_process->state = PROC_RUNNING;

    /* Need to change root page table in satp for the new process. */
    asm volatile("csrw satp, %0" : : "r"(current_process->satp));
    flush_tlb_global();

    /* Return new execution context to the assembly restore sequence. */
    return current_process->trapframe;
}

void spawn_payload_process() {
    process_t *p = find_free_slot(); 
    p->pid = next_pid++;

    /* Allocate a distinct Root Page Table for this process */
    uint64_t root_pt_phys = (uint64_t)alloc_page(); 
    uint64_t *root_pt_virt = (uint64_t *)__va((void*)root_pt_phys);
    
    /* Inherit the kernel's higher-half mappings so traps don't page fault. */
    /* This is fine to do because we still can't access those higher addresses even if we wanted to from user mode. */
    /* Without doing this, when we trapped into S-Mode, the MMU wouldn't be able to translate addresses for the (higher half) kernel. */
    memcpy(root_pt_virt, __root_pte, 4096);
    
    p->satp = (8ULL << 60) | (root_pt_phys >> 12); 

    /* Map the binary that we are injecting */
    uint64_t payload_size = (uint64_t)_dummy_bin_end - (uint64_t)_dummy_bin_start;
    uint64_t payload_phys = (uint64_t)alloc_page();
    void *payload_virt = (void *)__va((void*)payload_phys);
    
    memcpy(payload_virt, _dummy_bin_start, payload_size);

    /* Map into *this processes* page table at virtual address 0x0 */
    map_vaddr(root_pt_virt, 0x0, payload_phys, PTE_U | PTE_R | PTE_W | PTE_X);

    /* Map a User Stack (at 1GB here) */
    uint64_t stack_phys = (uint64_t)alloc_page();
    uint64_t stack_vaddr = 0x40000000; 
    map_vaddr(root_pt_virt, stack_vaddr - 4096, stack_phys, PTE_U | PTE_R | PTE_W);

    /* Fabricate the Trap Frame in Kernel Memory */
    /* This is needed, because otherwise, when we do an sret, the frame we would be using would be the one belonging to the kernel in its current context. */
    /* We set all the relevant registers so that when we return to user mode, we go to the current process virtual address 0, with all the right registers set. */
    uint64_t tf_phys = (uint64_t)alloc_page();
    p->trapframe = (pt_regs *)__va((void*)tf_phys);
    memset(p->trapframe, 0, sizeof(pt_regs));

    p->trapframe->sepc = 0x0; 
    p->trapframe->sp = stack_vaddr; 
    p->trapframe->sstatus = (1 << 5); /* SPIE = 1, SPP = 0 (U-mode) */

    p->state = PROC_RUNNING;

    p->state = PROC_READY;
}

pt_regs* pexit(pt_regs *regs) {
    if (current_process != 0) {
        sbi_printf("[Kernel] Reaping PID %d...\n", current_process->pid);
        current_process->state = PROC_UNUSED;
        current_process = 0;
    }
    
    return schedule(regs);
}
