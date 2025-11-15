project(rvos)

enable_language(ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/kernel/src")

set(CMAKE_LINKER ${TOOLCHAIN_PREFIX}ld)
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld)

set(CMAKE_C_FLAGS " -march=rv32im  ")
set(CMAKE_ASM_FLAGS " -march=rv32im_zicsr ")

add_executable(riscv ${SRC_DIR}/core/init.s ${SRC_DIR}/main.c)
target_link_options(
    riscv
    PRIVATE
        -T${LINKER_SCRIPT}
        -march=rv32im
        -fno-asynchronous-unwind-tables
        -fno-exceptions
        -nostartfiles
        -Wl,--strip-debug
        -Os
        -fno-align-functions
        -fomit-frame-pointer
        -nostdlib
        -lgcc
        -mabi=ilp32
        -fno-toplevel-reorder
)
