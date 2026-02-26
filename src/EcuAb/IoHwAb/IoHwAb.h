/**
 * @file    IoHwAb.h
 * @brief   I/O Hardware Abstraction Layer API
 *          ECU Abstraction Layer – bridges MCAL DIO to Application SWCs
 *
 *  Naming convention: IoHwAb_<Direction>_<SignalName>
 */
#ifndef IOHWAB_H
#define IOHWAB_H

#include "Std_Types.h"

/* --------------------------------------------------------------------------
 * Logical signal levels (application view, polarity-independent)
 * -------------------------------------------------------------------------- */
#define IOHWAB_SIG_ACTIVE    ((uint8)1u)   /* Switch pressed / LED on  */
#define IOHWAB_SIG_INACTIVE  ((uint8)0u)   /* Switch released / LED off */

/* --------------------------------------------------------------------------
 * API
 * -------------------------------------------------------------------------- */

/**
 * @brief  Read the logical state of USER Switch SW1.
 *         Abstracts the active-LOW polarity of the hardware.
 * @return IOHWAB_SIG_ACTIVE   – button is pressed
 *         IOHWAB_SIG_INACTIVE – button is released
 */
FUNC(uint8, IOHWAB_CODE) IoHwAb_Read_Sw1(void);

/**
 * @brief  Write the logical state of USER LED1.
 *         Abstracts the active-LOW polarity of the hardware.
 * @param  state  IOHWAB_SIG_ACTIVE (on) or IOHWAB_SIG_INACTIVE (off)
 */
FUNC(void, IOHWAB_CODE) IoHwAb_Write_Led1(uint8 state);

#endif /* IOHWAB_H */
