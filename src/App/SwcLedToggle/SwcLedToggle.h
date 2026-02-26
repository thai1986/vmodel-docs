/**
 * @file    SwcLedToggle.h
 * @brief   Application Software Component – LED Toggle
 *
 *  Runnable:  SwcLedToggle_Run10ms()
 *             – called every 10 ms by the main scheduler loop
 *             – reads SW1 and toggles LED1 on each button press edge
 */
#ifndef SWC_LED_TOGGLE_H
#define SWC_LED_TOGGLE_H

#include "Std_Types.h"

/**
 * @brief  10 ms runnable – SW1 pressed edge → toggle LED1.
 */
FUNC(void, SWC_CODE) SwcLedToggle_Run10ms(void);

#endif /* SWC_LED_TOGGLE_H */
