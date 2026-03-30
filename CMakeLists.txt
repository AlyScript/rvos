cmake_minimum_required(VERSION 3.25)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/riscv.cmake)

project(rvos LANGUAGES C ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld)
set(ROOT_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(KINCLUDE_DIR ${ROOT_INCLUDE}/kinclude)
set(UINCLUDE_DIR ${ROOT_INCLUDE}/uinclude)
set(SHARED_INCLUDE_DIR ${ROOT_INCLUDE}/sinclude)

set(RV_ARCH_FLAGS -march=rv64imac_zicsr_zifencei -mabi=lp64)

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
    ${SRC_DIR}/kernel/proc.c
    ${SRC_DIR}/payload.S
)

target_include_directories(
    kernel.bin
    PRIVATE ${KINCLUDE_DIR} ${SHARED_INCLUDE_DIR}
)

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

add_executable(dummy.elf ${SRC_DIR}/dummy.c ${SRC_DIR}/usr_lib.c)

target_include_directories(
    dummy.elf
    PRIVATE ${UINCLUDE_DIR} ${SHARED_INCLUDE_DIR}
)

target_compile_options(
    dummy.elf
    PRIVATE ${RV_ARCH_FLAGS} -O0 -ffreestanding -nostdlib -mcmodel=medany
)

target_link_options(
    dummy.elf
    PRIVATE ${RV_ARCH_FLAGS} -nostdlib -T${SRC_DIR}/user.ld
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/dummy.bin
    COMMAND
        riscv64-unknown-elf-objcopy -O binary $<TARGET_FILE:dummy.elf>
        ${CMAKE_CURRENT_BINARY_DIR}/dummy.bin
    DEPENDS dummy.elf
    COMMENT "Strip dummy.elf to raw flat binary dummy.bin"
)

add_executable(shell.elf ${SRC_DIR}/shell.c ${SRC_DIR}/usr_lib.c)

target_include_directories(
    shell.elf
    PRIVATE ${UINCLUDE_DIR} ${SHARED_INCLUDE_DIR}
)
target_compile_options(
    shell.elf
    PRIVATE ${RV_ARCH_FLAGS} -O0 -ffreestanding -nostdlib -mcmodel=medany
)
target_link_options(
    shell.elf
    PRIVATE ${RV_ARCH_FLAGS} -nostdlib -T${SRC_DIR}/user.ld
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/shell.bin
    COMMAND
        riscv64-unknown-elf-objcopy -O binary $<TARGET_FILE:shell.elf>
        ${CMAKE_CURRENT_BINARY_DIR}/shell.bin
    DEPENDS shell.elf
    COMMENT "Strip shell.elf to raw flat binary shell.bin"
)

add_custom_target(
    dummy_payload
    DEPENDS
        ${CMAKE_CURRENT_BINARY_DIR}/dummy.bin
        ${CMAKE_CURRENT_BINARY_DIR}/shell.bin
)

set_source_files_properties(
    ${SRC_DIR}/payload.S
    PROPERTIES
        OBJECT_DEPENDS
            "${CMAKE_CURRENT_BINARY_DIR}/dummy.bin;${CMAKE_CURRENT_BINARY_DIR}/shell.bin"
)

add_dependencies(kernel.bin dummy_payload)
