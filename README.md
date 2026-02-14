## Building

In the unlikely case that you are running RV64 natively, then all you need to run rvos is Qemu. Specifically, `qemu-system-riscv64` which is available via most package managers. 
Qemu is widely available in the *nix ecosystem via most package managers. For example, on any debian based machine, 
```sudo apt install qemu-system-riscv64```
should suffice.


In the much more likely case that you *aren't* on a RISCV platform, you'll want the [riscv toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) so that you can cross compile the binary for qemu. 

There are two options for installation, a Newlib cross-compiler and a Linux counterpart. The Newlib cross compiler is more than enough.

I wouldn't recommend using prebuilt binaries, but there are many available and I can't guarantee they'll be pain free. In any case, *make sure your toolchain targets 64-bit riscv.*

Once thats done, you can build the project.
```./build.sh```
will run some commands for you and spit out a binary in `build/`.

## Run
Use 
```./run.sh```
to start qemu with the kernel binary.

Should you wish to attach gdb, pass the `--debug` flag to the script
```./run.sh --debug```
and then attach gdb with 
```riscv64-unknown-elf-gdb build/kernel.bin```.

gdb _should_ use the `.gdbinit` in the project root which you can change to your liking. I use (dashboard)[https://github.com/cyrus-and/gdb-dashboard], but that's completely up to you.

