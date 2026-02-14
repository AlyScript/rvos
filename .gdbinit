dashboard -layout breakpoints variables expressions source assembly !history !memory registers !threads
dashboard source -style height 20

set architecture riscv:rv64
target remote :1234
symbol-file build/kernel.bin

