cmake_minimum_required(VERSION 3.25)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/riscv.cmake)

project(rvos LANGUAGES C ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld)
set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

set(RV_ARCH_FLAGS -march=rv64imac_zicsr -mabi=lp64)

add_executable(
    kernel.bin
    ${SRC_DIR}/kernel/start.S
    ${SRC_DIR}/kernel/kmain.c
    ${SRC_DIR}/kernel/trap.S
    ${SRC_DIR}/kernel/sbi.c
    ${SRC_DIR}/kernel/trap.c
    ${SRC_DIR}/kernel/interrupt.c
    ${SRC_DIR}/kernel/ecall.c
    ${SRC_DIR}/kernel/page.c
)

target_include_directories(kernel.bin PRIVATE ${INCLUDE_DIR})

target_compile_options(
    kernel.bin
    PRIVATE
        ${RV_ARCH_FLAGS}
        -O0
        -g
        -fno-builtin
        -fno-exceptions
        -Wall
        -Wextra
        -mcmodel=medany
)

target_link_options(
    kernel.bin
    PRIVATE ${RV_ARCH_FLAGS} -T${LINKER_SCRIPT} -nostdlib -nostartfiles -static
)

target_link_libraries(kernel.bin PRIVATE gcc)
