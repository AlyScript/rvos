; This file contains the implementation of the ecall functions
; The ecall functions are called by the user program in user mode
; Linux conventions have been loosely (but not strictly) followed

; ecall table
INCLUDE ecalls.s

; Libraries
INCLUDE ../../utils/print.s
INCLUDE ../../drivers/button.s
INCLUDE ../../drivers/rwtimer.s
INCLUDE ../../drivers/keypad.s

; We are (unconventionally) using ecall_0 to check for button presses
; Params:
    ; a0 = button number (1 - 4)
; Returns:
    ; a1 = button value (0 or 1)
ecall_0:
    subi sp, sp, 4
    sw ra, [sp]
    call button_read
    lw ra, [sp]
    addi sp, sp, 4
    ret

; We are (unconventionally) using ecall_0 to check for button presses
; Params:
;   None
; Returns:
    ; a0: 
ecall_1:

    ret

ecall_2:

ecall_3:
ecall_4:
ecall_5:
ecall_6:
ecall_7:
ecall_8:
ecall_9:
ecall_10:
ecall_11:
ecall_12:
ecall_13:
ecall_14:
ecall_15:
ecall_16:
ecall_17:
ecall_18:
ecall_19:
ecall_20:
ecall_21:
ecall_22:
ecall_23:
ecall_24:
ecall_25:
ecall_26:
ecall_27:
ecall_28:
ecall_29:
ecall_30:
ecall_31:
ecall_32:
ecall_33:
ecall_34:
ecall_35:
ecall_36:
ecall_37:
ecall_38:
ecall_39:
ecall_40:
ecall_41:
ecall_42:
ecall_43:
ecall_44:
ecall_45:
ecall_46:
ecall_47:
ecall_48:
ecall_49:
ecall_50:
ecall_51:
ecall_52:
ecall_53:
ecall_54:
ecall_55:
ecall_56:
ecall_57:
ecall_58:
ecall_59:
ecall_60:
ecall_61:
ecall_62:
ecall_63:

; write(2) - https://man7.org/linux/man-pages/man2/write.2.html
; Params:
    ; a0 = fd (we only support 1)
    ; a1 = buf (pointer to the string)
    ; a2 = count (number of bytes to write)
ecall_64:
    subi sp, sp, 4
    sw ra, [sp]
    call print
    lw ra, [sp]
    addi sp, sp, 4
    ret

; puts - write a single character to the HD44780 LCD display.
; // NOTE: This is not the conventional use for this ecall number! \\
; Params:
    ; a1 = character to print in ASCII (1 for Clear Screen)
    ; a2 = clear screen flag (0: No Clear, 1: Clear)
ecall_65:
    subi sp, sp, 4
    sw ra, [sp]
    call puts
    lw ra, [sp]
    addi sp, sp, 4
    ret

; Timer Write
; Params:
    ; a0 = value to write
    ; a1 = offset from the timer base address (see table 15.1) for the register to write
ecall_66:   
    subi sp, sp, 4
    sw ra, [sp]
    # call timer_write
    lw ra, [sp]
    addi sp, sp, 4
    ret

; Timer Read
; Params:
    ; a1 = offset from the timer base address (see table 15.1) for the register to read
; Returns:
    ; a0 = value of the specified timer register
ecall_67:
    subi sp, sp, 4
    sw ra, [sp]
    call timer_read
    lw ra, [sp]
    addi sp, sp, 4
    ret

ecall_68:
ecall_69:
ecall_70:
ecall_71:
ecall_72:
ecall_73:
ecall_74:
ecall_75:
ecall_76:
ecall_77:
ecall_78:
ecall_79:
ecall_80:
ecall_81:
ecall_82:
ecall_83:
ecall_84:
ecall_85:
ecall_86:
ecall_87:
ecall_88:
ecall_89:
ecall_90:
ecall_91:
ecall_92:
ecall_93:
ecall_94:
ecall_95:
ecall_96:
ecall_97:
ecall_98:
ecall_99:
ecall_100:
ecall_101:
ecall_102:
ecall_103:
ecall_104:
ecall_105:
ecall_106:
ecall_107:
ecall_108:
ecall_109:
ecall_110:
ecall_111:
ecall_112:
ecall_113:
ecall_114:
ecall_115:
ecall_116:
ecall_117:
ecall_118:
ecall_119:
ecall_120:
ecall_121:
ecall_122:
ecall_123:
ecall_124:
ecall_125:
ecall_126:
ecall_127:
ecall_128:

; kill(2) - https://man7.org/linux/man-pages/man2/kill.2.html
; Params:
    ; a0 = pid (not needed for our purposes)
    ; a1 = sig
    ; NOTE: Neither arguments are used here - we just halt the machine
ecall_129:
    li a2, 0x0001_0700              ; Load the address of the machine halt port
    sw zero, [a2]                   ; Write the value of a1 to the machine halt port
    j ecall_129                     ; We should (technically) never reach this point, so if we do then loop back

ecall_130:
ecall_invalid:
