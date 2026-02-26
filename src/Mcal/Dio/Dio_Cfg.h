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
 *   bits[7:4] = port number
 *   bits[3:0] = pin number
 * -------------------------------------------------------------------------- */
typedef uint8 Dio_ChannelType;
typedef uint8 Dio_LevelType;    /* STD_HIGH / STD_LOW                        */
typedef uint8 Dio_PortLevelType;

#define DIO_MAKE_CHANNEL(port, pin)  ((Dio_ChannelType)(((port) << 4u) | ((pin) & 0x0Fu)))
#define DIO_CHANNEL_PORT(ch)         ((uint8)(((ch) >> 4u) & 0x0Fu))
#define DIO_CHANNEL_PIN(ch)          ((uint8)((ch) & 0x0Fu))

/* --------------------------------------------------------------------------
 * Symbolic channel names
 * -------------------------------------------------------------------------- */
#define DIO_CHANNEL_SW1    DIO_MAKE_CHANNEL(7u,  0u)   /* USER Switch P7.0  */
#define DIO_CHANNEL_LED1   DIO_MAKE_CHANNEL(19u, 0u)   /* USER LED1   P19.0 */

#endif /* DIO_CFG_H */
