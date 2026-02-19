set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(COMMON_FLAGS "-mcpu=cortex-m7 -mthumb -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS_INIT "${COMMON_FLAGS} -std=c11")
set(CMAKE_CXX_FLAGS_INIT "${COMMON_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT "${COMMON_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,--gc-sections")
