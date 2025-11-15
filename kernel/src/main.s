; The user space application! We jump here from the machine mode initialisation.

; -----------------------------------------------------------
;INCLUDE apps/stopwatch.s
INCLUDE apps/numberpunch.s

ORG 0x0004_0000

j _start

; We keep main.s simple, and include the actual code in other files.

STR DEFB "Hello, World!\0"
ALIGN

_start

    call numberpunch
    
halt
    la a7, 129              ; SIGKILL
    ecall
    j halt                  ; Just in case the ecall fails, but we should never return


ORG 0x80000 - 300
STACK_END DEFS 300          ; 100 bytes of stack space.. 25 words
STACK                       ; Stack ends at 0x80000   