#!/bin/bash 
# A Mathews 2025
#
# A very simple scripts
# Build tools such as CMake or Make 
# may be more appropriate
#
# Please ask a a member of staff for additional  
# help


# Compile to a.out 
# -g    Debug symbols
# -T    Sepcify a custom linker script 
riscv32-unknown-elf-gcc *.c -g \
                            -fno-align-functions  -Os -Wall -fomit-frame-pointer \
                            -fno-asynchronous-unwind-tables -fno-exceptions      \
                            -march=rv32im -mabi=ilp32  -lm -nostdlib            \
                            -mabi=ilp32   \
                            -T "./board.ld"    # Use a special linker scripts
