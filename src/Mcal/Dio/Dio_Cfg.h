/**
 * @file    Dio_Cfg.h
 * @brief   AUTOSAR DIO Driver – Channel Configuration
 *          Board: CYTVII-B-E-1M-SK   MCU: CYT2B75XX
 */
#ifndef DIO_CFG_H
#define DIO_CFG_H

#include "Std_Types.h"

/* --------------------------------------------------------------------------
 * Dio_ChannelType encodes port and pin:
 *   bits[15:8] = port number
 *   bits[7:0]  = pin number
 *
 * NOTE:
 *   Some CYT2B75XX ports are > 15 (e.g. LED1 on P19.0), so an 8-bit channel
 *   encoding would overflow and target the wrong GPIO port.
 * -------------------------------------------------------------------------- */
typedef uint16 Dio_ChannelType;
typedef uint8 Dio_LevelType;    /* STD_HIGH / STD_LOW                        */
typedef uint8 Dio_PortLevelType;

#define DIO_MAKE_CHANNEL(port, pin)  ((Dio_ChannelType)((((uint16)(port)) << 8u) | ((uint16)(pin) & 0x00FFu)))
#define DIO_CHANNEL_PORT(ch)         ((uint8)((((uint16)(ch)) >> 8u) & 0x00FFu))
#define DIO_CHANNEL_PIN(ch)          ((uint8)(((uint16)(ch)) & 0x00FFu))

/* --------------------------------------------------------------------------
 * Symbolic channel names
 * -------------------------------------------------------------------------- */
#define DIO_CHANNEL_SW1    DIO_MAKE_CHANNEL(7u,  0u)   /* USER Switch P7.0  */
#define DIO_CHANNEL_LED1   DIO_MAKE_CHANNEL(19u, 0u)   /* USER LED1   P19.0 */

#endif /* DIO_CFG_H */
