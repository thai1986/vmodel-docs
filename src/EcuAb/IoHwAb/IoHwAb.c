/**
 * @file    IoHwAb.c
 * @brief   I/O Hardware Abstraction Layer – Implementation
 *
 *  Polarity mapping (from User Guide 002-25314 Rev.*B):
 *    SW1  (P7.0)  – active-LOW: pin=LOW  → pressed
 *    LED1 (P19.0) – active-LOW: pin=LOW  → on
 */
#include "IoHwAb.h"
#include "Dio.h"

/* --------------------------------------------------------------------------
 * IoHwAb_Read_Sw1
 * -------------------------------------------------------------------------- */
FUNC(uint8, IOHWAB_CODE) IoHwAb_Read_Sw1(void)
{
    Dio_LevelType pinLevel = Dio_ReadChannel(DIO_CHANNEL_SW1);

    /* Active-LOW: STD_LOW on the pin means the button is pressed */
    return (pinLevel == STD_LOW) ? IOHWAB_SIG_ACTIVE : IOHWAB_SIG_INACTIVE;
}

/* --------------------------------------------------------------------------
 * IoHwAb_Write_Led1
 * -------------------------------------------------------------------------- */
FUNC(void, IOHWAB_CODE) IoHwAb_Write_Led1(uint8 state)
{
    /* Active-LOW LED: drive STD_LOW to light it, STD_HIGH to extinguish */
    Dio_LevelType pinLevel = (state == IOHWAB_SIG_ACTIVE) ? STD_LOW : STD_HIGH;

    Dio_WriteChannel(DIO_CHANNEL_LED1, pinLevel);
}
