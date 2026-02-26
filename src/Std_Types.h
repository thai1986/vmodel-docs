/**
 * @file    Std_Types.h
 * @brief   AUTOSAR Standard Types (AUTOSAR SWS_StandardTypes)
 */
#ifndef STD_TYPES_H
#define STD_TYPES_H

#include "Platform_Types.h"
#include "Compiler.h"

typedef uint8 Std_ReturnType;

#define E_OK        ((Std_ReturnType)0u)
#define E_NOT_OK    ((Std_ReturnType)1u)

#define STD_HIGH    ((uint8)1u)
#define STD_LOW     ((uint8)0u)

#define STD_ACTIVE  ((uint8)1u)
#define STD_IDLE    ((uint8)0u)

#define STD_ON      ((uint8)1u)
#define STD_OFF     ((uint8)0u)

typedef struct
{
    uint16  vendorID;
    uint16  moduleID;
    uint8   sw_major_version;
    uint8   sw_minor_version;
    uint8   sw_patch_version;
} Std_VersionInfoType;

#endif /* STD_TYPES_H */
