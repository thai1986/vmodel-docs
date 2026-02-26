/**
 * @file    Port_Cfg.h
 * @brief   AUTOSAR Port Driver – Static Configuration
 *          Board: CYTVII-B-E-1M-SK   MCU: CYT2B75XX
 *
 * Pin assignments (User Guide 002-25314 Rev.*B)
 * -----------------------------------------------
 *  PORT_PIN_SW1   P7.0  QFP-29  Input,  pull-up   (USER Switch, active-LOW)
 *  PORT_PIN_LED1  P19.0 QFP-77  Output, strong     (USER LED1 Blue, active-LOW)
 */
#ifndef PORT_CFG_H
#define PORT_CFG_H

#include "Std_Types.h"

/* --------------------------------------------------------------------------
 * Port/Pin identifiers
 * -------------------------------------------------------------------------- */
#define PORT_PIN_SW1_PORT    ((uint8)7u)
#define PORT_PIN_SW1_PIN     ((uint8)0u)

#define PORT_PIN_LED1_PORT   ((uint8)19u)
#define PORT_PIN_LED1_PIN    ((uint8)0u)

/* --------------------------------------------------------------------------
 * Drive modes (maps to CYT2B75XX PRT_PC 3-bit field)
 * -------------------------------------------------------------------------- */
#define PORT_DM_PULLUP       ((uint8)0x2u)   /* Resistive pull-up (input)  */
#define PORT_DM_STRONG       ((uint8)0x6u)   /* Strong drive      (output) */

/* --------------------------------------------------------------------------
 * Number of pins configured at startup
 * -------------------------------------------------------------------------- */
#define PORT_NUM_PINS        (2u)

/* --------------------------------------------------------------------------
 * Pin configuration structure type
 * -------------------------------------------------------------------------- */
typedef struct
{
    uint8  port;         /* GPIO port number       */
    uint8  pin;          /* Pin number within port */
    uint8  driveMode;    /* PORT_DM_xxx            */
    uint8  initValue;    /* STD_HIGH / STD_LOW     */
} Port_PinConfigType;

/* --------------------------------------------------------------------------
 * Static configuration table (defined in Port_Cfg.c / Port.c)
 * -------------------------------------------------------------------------- */
extern const Port_PinConfigType Port_PinConfig[PORT_NUM_PINS];

#endif /* PORT_CFG_H */
