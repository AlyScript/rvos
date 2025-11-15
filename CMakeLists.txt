set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/riscv.cmake)
project(rvos)

enable_language(ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/kernel/src)

set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld)

add_executable(prog.elf ${SRC_DIR}/core/init.s ${SRC_DIR}/main.c)
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
            ${CMAKE_CURRENT_SOURCE_DIR}/elf/elftokmd $<TARGET_FILE:prog.elf>
            ${CMAKE_CURRENT_BINARY_DIR}/prog.kmd
        COMMENT "Creating .kmd file"
        VERBATIM
    )
endif()
