.section .text
.global zero_bss

zero_bss:
    la   a0, __bss_start          /* load start address */
    la   a1, __bss_end            /* load end address   */
    li   a2, 0                    /* value to store     */

1:
    sw   a2, 0(a0)                /* store zero */
    addi a0, a0, 4                /* advance pointer */
    bltu a0, a1, 1b               /* loop while a0 < a1 */

    ret
    .size zero_bss, .-zero_bss
