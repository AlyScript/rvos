; header file for interrupt service routines

isr_jump
    DEFW isr_0
    DEFW isr_1
    DEFW isr_2
    DEFW isr_3
    DEFW isr_4          ; Timer has reached its terminal count (at least once)
    DEFW isr_5
    DEFW isr_6
    DEFW isr_7
    DEFW isr_8
    DEFW isr_9
    DEFW isr_10