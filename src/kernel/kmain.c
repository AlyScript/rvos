#include <stdint.h>
#include <page.h>

extern void __shandler(void);

extern void spawn_payload_process(void);

void kmain(uint64_t hartid, uint64_t dtb) {
    (void)hartid; 
    (void)dtb;

    asm volatile("csrw stvec, %0" : : "r"(__shandler));

    spawn_payload_process();

    /* Shouldn't ever get here */
    while (1) {
        asm volatile("wfi"); 
    }
}
