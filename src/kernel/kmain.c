#include <stdint.h>
#include <page.h>
#include <proc.h>
#include <sbi.h>

extern char _shell_bin_start[];
extern char _shell_bin_end[];

extern void __shandler();
extern void timer_init();

void kmain(uint64_t hartid, uint64_t dtb) {
    (void)hartid; 
    (void)dtb;

    asm volatile("csrw stvec, %0" : : "r"(__shandler));

    sbi_printf("OS: Starting Interactive Shell...\n");
    spawn_payload_process(_shell_bin_start, _shell_bin_end); 
    asm volatile("csrw sscratch, %0" : : "r"(process_table[0].trapframe));

    timer_init();

    asm volatile("csrs sstatus, %0" : : "r"(1 << 1)); // Set SIE bit

    /* Should hang here until the timer fires then scheduler should do its work. */
    while (1) {
        asm volatile("wfi"); 
    }
}
