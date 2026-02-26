cmake_minimum_required(VERSION 3.20)
project(traveo2_starter C ASM)

# ---------------------------------------------------------------------------
# Source files  (AUTOSAR layered architecture)
#   Base     : Std_Types, Platform_Types, Compiler (header-only)
#   MCAL     : Port, Dio
#   EcuAb    : IoHwAb
#   App      : SwcLedToggle
# ---------------------------------------------------------------------------
add_executable(${PROJECT_NAME}.elf
    src/main.c
    src/Mcal/Port/Port.c
    src/Mcal/Dio/Dio.c
    src/EcuAb/IoHwAb/IoHwAb.c
    src/App/SwcLedToggle/SwcLedToggle.c
)

# ---------------------------------------------------------------------------
# Include directories (one per layer)
# ---------------------------------------------------------------------------
target_include_directories(${PROJECT_NAME}.elf PRIVATE
    src                          # Std_Types.h, Platform_Types.h, Compiler.h
    src/Mcal/Port
    src/Mcal/Dio
    src/EcuAb/IoHwAb
    src/App/SwcLedToggle
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
