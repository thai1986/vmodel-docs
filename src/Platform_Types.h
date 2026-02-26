/**
 * @file    Platform_Types.h
 * @brief   AUTOSAR Platform Types (AUTOSAR SWS_PlatformTypes)
 * @note    Target: CYT2B75XX  Arm Cortex-M4F  32-bit little-endian
 *          Types defined directly - no stdint.h to avoid conflicts
 *          with bare-metal ARM toolchain headers.
 */
#ifndef PLATFORM_TYPES_H
#define PLATFORM_TYPES_H

typedef unsigned char               uint8;
typedef unsigned short              uint16;
typedef unsigned long               uint32;
typedef unsigned long long          uint64;

typedef signed char                 sint8;
typedef signed short                sint16;
typedef signed long                 sint32;
typedef signed long long            sint64;

typedef float                       float32;
typedef double                      float64;

typedef uint8                       boolean;

/* uintptr_t equivalent for Cortex-M4 (32-bit address space) */
typedef unsigned long               uintptr_t;

#define TRUE   ((boolean)1u)
#define FALSE  ((boolean)0u)

#endif /* PLATFORM_TYPES_H */
