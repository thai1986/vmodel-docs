/**
 * @file    Dio.c
 * @brief   AUTOSAR DIO Driver Implementation
 *          Hardware: CYT2B75XX  GPIO registers
 */
#include "Dio.h"

/* --------------------------------------------------------------------------
 * CYT2B75XX  GPIO register map
 * -------------------------------------------------------------------------- */
#define GPIO_BASE          (0x40310000UL)
#define GPIO_PORT_STRIDE   (0x80UL)

#define PRT_DR             (0x00UL)   /* Output data register              */
#define PRT_PS             (0x04UL)   /* Pin state  (input read)           */

#define REG32(addr)        (*(volatile uint32 *)(uintptr_t)(addr))

/* --------------------------------------------------------------------------
 * Dio_ReadChannel
 * -------------------------------------------------------------------------- */
FUNC(Dio_LevelType, DIO_CODE) Dio_ReadChannel(Dio_ChannelType ChannelId)
{
    uint8  port     = DIO_CHANNEL_PORT(ChannelId);
    uint8  pin      = DIO_CHANNEL_PIN(ChannelId);
    uint32 gpio_prt = GPIO_BASE + ((uint32)port * GPIO_PORT_STRIDE);
    uint32 raw      = (REG32(gpio_prt + PRT_PS) >> pin) & 1UL;

    return (raw != 0UL) ? STD_HIGH : STD_LOW;
}

/* --------------------------------------------------------------------------
 * Dio_WriteChannel
 * -------------------------------------------------------------------------- */
FUNC(void, DIO_CODE) Dio_WriteChannel(Dio_ChannelType ChannelId,
                                      Dio_LevelType   Level)
{
    uint8  port     = DIO_CHANNEL_PORT(ChannelId);
    uint8  pin      = DIO_CHANNEL_PIN(ChannelId);
    uint32 gpio_prt = GPIO_BASE + ((uint32)port * GPIO_PORT_STRIDE);

    if (Level == STD_HIGH)
    {
        REG32(gpio_prt + PRT_DR) |=  (1UL << pin);
    }
    else
    {
        REG32(gpio_prt + PRT_DR) &= ~(1UL << pin);
    }
}

/* --------------------------------------------------------------------------
 * Dio_FlipChannel
 * -------------------------------------------------------------------------- */
FUNC(Dio_LevelType, DIO_CODE) Dio_FlipChannel(Dio_ChannelType ChannelId)
{
    Dio_LevelType current = Dio_ReadChannel(ChannelId);
    Dio_LevelType next    = (current == STD_HIGH) ? STD_LOW : STD_HIGH;

    Dio_WriteChannel(ChannelId, next);

    return next;
}
