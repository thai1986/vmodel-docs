/**
 * @file    Dio.h
 * @brief   AUTOSAR DIO Driver API  (AUTOSAR SWS_DIODriver)
 */
#ifndef DIO_H
#define DIO_H

#include "Std_Types.h"
#include "Dio_Cfg.h"

/* --------------------------------------------------------------------------
 * Module version
 * -------------------------------------------------------------------------- */
#define DIO_VENDOR_ID           (0u)
#define DIO_MODULE_ID           (120u)   /* AUTOSAR module ID for Dio     */
#define DIO_SW_MAJOR_VERSION    (1u)
#define DIO_SW_MINOR_VERSION    (0u)
#define DIO_SW_PATCH_VERSION    (0u)

/* --------------------------------------------------------------------------
 * API
 * -------------------------------------------------------------------------- */

/**
 * @brief  Read a DIO channel.
 * @param  ChannelId  Channel to read (DIO_CHANNEL_xxx)
 * @return STD_HIGH or STD_LOW
 */
FUNC(Dio_LevelType, DIO_CODE) Dio_ReadChannel(Dio_ChannelType ChannelId);

/**
 * @brief  Write a DIO channel.
 * @param  ChannelId  Channel to write (DIO_CHANNEL_xxx)
 * @param  Level      STD_HIGH or STD_LOW
 */
FUNC(void, DIO_CODE) Dio_WriteChannel(Dio_ChannelType ChannelId,
                                      Dio_LevelType   Level);

/**
 * @brief  Flip the current output level of a DIO channel.
 * @param  ChannelId  Channel to flip
 * @return New level after toggle
 */
FUNC(Dio_LevelType, DIO_CODE) Dio_FlipChannel(Dio_ChannelType ChannelId);

#endif /* DIO_H */
