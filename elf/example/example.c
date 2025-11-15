
#include "lib.h"



#define DEVICE_MEMORY_LOCATION 0x10100;
 
/** We use a special GCC directive to make sure this code is placed
    at the starting point of the program in memory at position 0.
    See board.ld (a linker script) for more details.
 */
#define STARTUP_ATTRIBUTE   __attribute__((section(".text.startup")))

void _start() STARTUP_ATTRIBUTE;

int user_main();

int something() { 

    return -1;
}

/** Startup function  */
void _start()   {

    user_main();
}

/** Actual main function */
int user_main() {

    /** Calculating some useful value */
    int a = some_lib(3, 8);

    /** Pointer into device memory  */
    volatile register int *memory = (int*) DEVICE_MEMORY_LOCATION;

    /** Writing to device memory */
    *memory = a;
}