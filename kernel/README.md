Custom RISC-V (RV32IM) implementation in use here.

The assembler can be run with
```bash
./riscv/riscasm
```
which provides example usage.

Ensure that the file is executable by running
```bash
sudo chmod +x riscv/riscasm
```

NOTE: The assembler runs on x86 architecture.

## ECALLs
See [this page](https://man7.org/linux/man-pages/man2/syscall.2.html) to see conventions for RISC-V system calls or "ECALL".

Also [here](https://jborza.com/post/2021-05-11-riscv-linux-syscalls/) for the RISC-V syscall table.
