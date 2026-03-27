.section .rodata
.global _dummy_bin_start
.global _dummy_bin_end
.align 4

_dummy_bin_start:
    .incbin "dummy.bin"
_dummy_bin_end:
