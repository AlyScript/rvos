# the name of the target operating system
set(CMAKE_SYSTEM_NAME Generic)

# which compilers to use for C and C++
set(CMAKE_C_COMPILER /opt/riscv32/bin/riscv32-unknown-elf-gcc)
set(CMAKE_ASM_COMPILER /opt/riscv32/bin/riscv32-unknown-elf-as)
set(CMAKE_CXX_COMPILER /opt/riscv32/bin/riscv32-unknown-elf-g++)
set(CMAKE_LINKER /opt/riscv32/bin/riscv32-unknown-elf-ld)

# where is the target environment located
set(CMAKE_FIND_ROOT_PATH /opt/riscv32/)

# adjust the default behavior of the FIND_XXX() commands:
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_C_FLAGS "-march=rv32im_zicsr -mabi=ilp32")
set(CMAKE_ASM_FLAGS "-march=rv32im_zicsr -mabi=ilp32")
