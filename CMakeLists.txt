set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/riscv.cmake)
project(rvos)

enable_language(ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/kernel/src)

set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld)

set(NEWLIB_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/newlib)

add_executable(
    prog.elf
    ${SRC_DIR}/core/init.s
    ${SRC_DIR}/core/trap_new.s
    ${SRC_DIR}/core/interrupt/interrupt.s
    ${SRC_DIR}/core/ecall/ecall_new.c
    ${SRC_DIR}/core/zerobss.s
    ${SRC_DIR}/main.c
    ${SRC_DIR}/syscalls/syscalls.c
)
target_include_directories(prog.elf PRIVATE ${NEWLIB_ROOT}/include)
target_link_directories(prog.elf PRIVATE ${NEWLIB_ROOT}/lib)
target_link_libraries(prog.elf PRIVATE c gcc)
target_link_options(
    prog.elf
    PRIVATE
        -T${LINKER_SCRIPT}
        -fno-exceptions
        -nostartfiles
        -nostdlib
        -march=rv32im_zicsr
        -mabi=ilp32
)

option(MAKE_KMD "Generate .kmd file from the ELF (default ON)" ON)
if(MAKE_KMD)
    add_custom_command(
        TARGET prog.elf
        POST_BUILD
        COMMAND
            ${CMAKE_CURRENT_SOURCE_DIR}/etok/objdump.sh $<TARGET_FILE:prog.elf>
            prog.kmd
        COMMAND
            python3 ${CMAKE_CURRENT_SOURCE_DIR}/etok/main.py
            executable_sections.txt data.txt prog.kmd
        COMMENT "Creating .kmd file"
        VERBATIM
    )
endif()
