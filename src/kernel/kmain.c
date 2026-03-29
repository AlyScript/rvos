#include <stdint.h>
#include <page.h>
#include <proc.h>

extern void __shandler();
extern void timer_init();

void kmain(uint64_t hartid, uint64_t dtb) {
    (void)hartid; 
    (void)dtb;

    asm volatile("csrs sstatus, %0" : : "r"(1 << 1)); /* Set SIE for global interrupts. */
    asm volatile("csrw stvec, %0" : : "r"(__shandler));

    spawn_payload_process();
    asm volatile("csrw sscratch, %0" : : "r"(process_table[0].trapframe));
    spawn_payload_process();
    spawn_payload_process();
    spawn_payload_process();

    timer_init();

    asm volatile("csrs sstatus, %0" : : "r"(1 << 1)); // Set SIE bit

    /* Should hang here until the timer fires then scheduler should do its work. */
    while (1) {
        asm volatile("wfi"); 
    }
}
