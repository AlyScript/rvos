#!/bin/bash

INFILE=$1
OUTFILE=$2

# Read text sections
riscv32-unknown-elf-readelf -S --wide $INFILE | grep "AX" | awk 'match($0,/\] ([^ ]+)/,a){print a[1]}' | xargs -I {} riscv32-unknown-elf-objdump -d -S --section={} $INFILE > executable_sections.txt

# Read data sections
riscv32-unknown-elf-readelf -S --wide $INFILE | grep -v "AX" | awk 'match($0,/\] ([^ ]+)/,a){print a[1]}' | xargs -I {} riscv32-unknown-elf-objdump -s --section={} $INFILE > data.txt

riscv32-unknown-elf-objcopy -O binary $INFILE $OUTFILE
