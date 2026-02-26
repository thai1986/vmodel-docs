/**
 * @file    Port.h
 * @brief   AUTOSAR Port Driver API  (AUTOSAR SWS_PortDriver)
 */
#ifndef PORT_H
#define PORT_H

#include "Std_Types.h"
#include "Port_Cfg.h"

/* --------------------------------------------------------------------------
 * Service IDs (for Det reporting, simplified)
 * -------------------------------------------------------------------------- */
#define PORT_INIT_ID              (0x00u)
#define PORT_SET_PIN_DIRECTION_ID (0x01u)

/* --------------------------------------------------------------------------
 * Module version
 * -------------------------------------------------------------------------- */
#define PORT_VENDOR_ID            (0u)
#define PORT_MODULE_ID            (124u)   /* AUTOSAR module ID for Port    */
#define PORT_SW_MAJOR_VERSION     (1u)
#define PORT_SW_MINOR_VERSION     (0u)
#define PORT_SW_PATCH_VERSION     (0u)

/* --------------------------------------------------------------------------
 * API
 * -------------------------------------------------------------------------- */

/**
 * @brief  Initialise all configured port pins.
 *         Must be called once before any other Port / Dio function.
 */
FUNC(void, PORT_CODE) Port_Init(void);

#endif /* PORT_H */
