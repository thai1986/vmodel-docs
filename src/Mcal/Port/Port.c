/**
 * @file    Port.c
 * @brief   AUTOSAR Port Driver Implementation
 *          Hardware: CYT2B75XX  GPIO / HSIOM registers
 */
#include "Port.h"

/* --------------------------------------------------------------------------
 * CYT2B75XX  GPIO / HSIOM register map
 * Reference: TRAVEO II TRM 002-19314
 * -------------------------------------------------------------------------- */
#define GPIO_BASE             (0x40310000UL)
#define HSIOM_BASE            (0x40300000UL)
#define GPIO_PORT_STRIDE      (0x80UL)
#define HSIOM_PORT_STRIDE     (0x100UL)

#define PRT_DR                (0x00UL)   /* Output data register          */
#define PRT_PC                (0x08UL)   /* Drive mode  (3 bits per pin)  */

#define HSIOM_PORT_SEL0       (0x00UL)   /* HSIOM select  pins 0-3        */
#define HSIOM_PORT_SEL1       (0x04UL)   /* HSIOM select  pins 4-7        */
#define HSIOM_GPIO            (0x00UL)   /* Pin connected to GPIO         */

#define REG32(addr)           (*(volatile uint32 *)(uintptr_t)(addr))

/* --------------------------------------------------------------------------
 * Static configuration table (one entry per configured pin)
 * -------------------------------------------------------------------------- */
const Port_PinConfigType Port_PinConfig[PORT_NUM_PINS] =
{
    /* PORT_PIN_SW1  – P7.0 – input pull-up, init HIGH (released) */
    {
        PORT_PIN_SW1_PORT,
        PORT_PIN_SW1_PIN,
        PORT_DM_PULLUP,
        STD_HIGH
    },
    /* PORT_PIN_LED1 – P19.0 – output strong, init HIGH (LED off, active-low) */
    {
        PORT_PIN_LED1_PORT,
        PORT_PIN_LED1_PIN,
        PORT_DM_STRONG,
        STD_HIGH
    }
};

/* --------------------------------------------------------------------------
 * Internal helpers
 * -------------------------------------------------------------------------- */
static void Port_Hw_SetHsiomGpio(uint8 port, uint8 pin)
{
    uint32 hsiom_prt  = HSIOM_BASE + ((uint32)port * HSIOM_PORT_STRIDE);
    uint32 sel_reg    = (pin < 4u) ? HSIOM_PORT_SEL0 : HSIOM_PORT_SEL1;
    uint32 bit_shift  = (pin < 4u) ? ((uint32)pin * 8u) : (((uint32)pin - 4u) * 8u);

    REG32(hsiom_prt + sel_reg) &= ~(0xFFUL << bit_shift);
    /* HSIOM_GPIO == 0, so cleared field = GPIO; explicit write for clarity */
    REG32(hsiom_prt + sel_reg) |=  (HSIOM_GPIO << bit_shift);
}

static void Port_Hw_SetDriveMode(uint8 port, uint8 pin, uint8 driveMode)
{
    uint32 gpio_prt  = GPIO_BASE + ((uint32)port * GPIO_PORT_STRIDE);
    uint32 pc_shift  = (uint32)pin * 3u;

    REG32(gpio_prt + PRT_PC) &= ~(0x7UL  << pc_shift);
    REG32(gpio_prt + PRT_PC) |=  ((uint32)driveMode << pc_shift);
}

static void Port_Hw_WritePin(uint8 port, uint8 pin, uint8 value)
{
    uint32 gpio_prt = GPIO_BASE + ((uint32)port * GPIO_PORT_STRIDE);

    if (value == STD_HIGH)
    {
        REG32(gpio_prt + PRT_DR) |=  (1UL << pin);
    }
    else
    {
        REG32(gpio_prt + PRT_DR) &= ~(1UL << pin);
    }
}

/* --------------------------------------------------------------------------
 * Port_Init
 * -------------------------------------------------------------------------- */
FUNC(void, PORT_CODE) Port_Init(void)
{
    uint8 i;

    for (i = 0u; i < (uint8)PORT_NUM_PINS; i++)
    {
        const Port_PinConfigType * const cfg = &Port_PinConfig[i];

        Port_Hw_SetHsiomGpio(cfg->port, cfg->pin);
        Port_Hw_WritePin    (cfg->port, cfg->pin, cfg->initValue);
        Port_Hw_SetDriveMode(cfg->port, cfg->pin, cfg->driveMode);
    }
}
