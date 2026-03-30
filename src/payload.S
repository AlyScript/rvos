.section .rodata
.align 4

.global _dummy_bin_start
.global _dummy_bin_end
_dummy_bin_start:
    .incbin "dummy.bin"
_dummy_bin_end:

.align 4

.global _shell_bin_start
.global _shell_bin_end
_shell_bin_start:
    .incbin "shell.bin"
_shell_bin_end:
