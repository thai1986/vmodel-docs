cmake_minimum_required(VERSION 3.20)
project(traveo2_starter C ASM)

add_executable(${PROJECT_NAME}.elf
    src/main.c
)

target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
    CYTVII_B_E_1M_SK=1
)

target_compile_options(${PROJECT_NAME}.elf PRIVATE
    -Wall
    -Wextra
)

target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T${CMAKE_SOURCE_DIR}/linker/traveo2_1m.ld
    -Wl,-Map=${CMAKE_BINARY_DIR}/traveo2_starter.map
    -nostartfiles
)
