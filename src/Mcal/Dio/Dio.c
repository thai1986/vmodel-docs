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
#define PRT_PS             (0x10UL)   /* IN register (input read)           */

#define REG32(addr)        (*(volatile uint32 *)(uintptr_t)(addr))

#if defined(ENABLE_SW1_SIMULATION)
/*
 * SW1 simulation state machine tuned for automated functional Robot tests.
 * It generates: press-1, press-2, then a long hold, with phase changes tied
 * to observed LED output transitions so it is resilient to loop timing drift.
 */
typedef enum
{
    SW1_SIM_PHASE_WAIT_1 = 0,
    SW1_SIM_PHASE_PRESS_1,
    SW1_SIM_PHASE_WAIT_2,
    SW1_SIM_PHASE_PRESS_2,
    SW1_SIM_PHASE_WAIT_3,
    SW1_SIM_PHASE_PRESS_3_HOLD,
    SW1_SIM_PHASE_DONE
} Dio_Sw1SimPhaseType;

#define SW1_SIM_WAIT1_TICKS        (20UL)
#define SW1_SIM_WAIT2_TICKS        (5UL)
#define SW1_SIM_WAIT3_TICKS        (5UL)
#define SW1_SIM_MIN_PRESS_TICKS    (3UL)
#define SW1_SIM_MAX_PRESS_TICKS    (15UL)
#define SW1_SIM_HOLD_TICKS         (50UL)

#define LED1_SIM_PORT              (19UL)
#define LED1_SIM_PIN               (0UL)

static VAR(Dio_Sw1SimPhaseType, DIO_VAR) Dio_Sw1SimPhase = SW1_SIM_PHASE_WAIT_1;
static VAR(uint32, DIO_VAR) Dio_Sw1SimPhaseTicks = 0UL;

static FUNC(uint32, DIO_CODE) Dio_ReadLed1DrBit(void)
{
    uint32 gpio_prt = GPIO_BASE + (LED1_SIM_PORT * GPIO_PORT_STRIDE);
    return (REG32(gpio_prt + PRT_DR) >> LED1_SIM_PIN) & 1UL;
}

static FUNC(Dio_LevelType, DIO_CODE) Dio_SimulateSw1Level(void)
{
    uint32 led_dr = Dio_ReadLed1DrBit();
    Dio_LevelType level = STD_HIGH;

    switch (Dio_Sw1SimPhase)
    {
        case SW1_SIM_PHASE_WAIT_1:
            Dio_Sw1SimPhaseTicks++;
            if (Dio_Sw1SimPhaseTicks >= SW1_SIM_WAIT1_TICKS)
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_PRESS_1;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            break;

        case SW1_SIM_PHASE_PRESS_1:
            level = STD_LOW;
            Dio_Sw1SimPhaseTicks++;
            if ((Dio_Sw1SimPhaseTicks >= SW1_SIM_MIN_PRESS_TICKS) && (led_dr == 0UL))
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_WAIT_2;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            else if (Dio_Sw1SimPhaseTicks >= SW1_SIM_MAX_PRESS_TICKS)
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_WAIT_2;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            break;

        case SW1_SIM_PHASE_WAIT_2:
            Dio_Sw1SimPhaseTicks++;
            if (Dio_Sw1SimPhaseTicks >= SW1_SIM_WAIT2_TICKS)
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_PRESS_2;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            break;

        case SW1_SIM_PHASE_PRESS_2:
            level = STD_LOW;
            Dio_Sw1SimPhaseTicks++;
            if ((Dio_Sw1SimPhaseTicks >= SW1_SIM_MIN_PRESS_TICKS) && (led_dr != 0UL))
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_WAIT_3;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            else if (Dio_Sw1SimPhaseTicks >= SW1_SIM_MAX_PRESS_TICKS)
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_WAIT_3;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            break;

        case SW1_SIM_PHASE_WAIT_3:
            Dio_Sw1SimPhaseTicks++;
            if (Dio_Sw1SimPhaseTicks >= SW1_SIM_WAIT3_TICKS)
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_PRESS_3_HOLD;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            break;

        case SW1_SIM_PHASE_PRESS_3_HOLD:
            level = STD_LOW;
            Dio_Sw1SimPhaseTicks++;
            if (Dio_Sw1SimPhaseTicks >= SW1_SIM_HOLD_TICKS)
            {
                Dio_Sw1SimPhase = SW1_SIM_PHASE_DONE;
                Dio_Sw1SimPhaseTicks = 0UL;
            }
            break;

        case SW1_SIM_PHASE_DONE:
        default:
            break;
    }

    return level;
}
#endif

/* --------------------------------------------------------------------------
 * Dio_ReadChannel
 * -------------------------------------------------------------------------- */
FUNC(Dio_LevelType, DIO_CODE) Dio_ReadChannel(Dio_ChannelType ChannelId)
{
    uint8  port     = DIO_CHANNEL_PORT(ChannelId);
    uint8  pin      = DIO_CHANNEL_PIN(ChannelId);
    uint32 gpio_prt = GPIO_BASE + ((uint32)port * GPIO_PORT_STRIDE);
    uint32 raw      = (REG32(gpio_prt + PRT_PS) >> pin) & 1UL;

#if defined(ENABLE_SW1_SIMULATION)
    if (ChannelId == DIO_CHANNEL_SW1)
    {
        return Dio_SimulateSw1Level();
    }
#endif

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
