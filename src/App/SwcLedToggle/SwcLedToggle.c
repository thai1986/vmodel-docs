/**
 * @file    SwcLedToggle.c
 * @brief   Application SWC – LED Toggle on SW1 press
 *
 *  Architecture layer : Application (SWC)
 *  Accesses hardware   : exclusively through IoHwAb (ECU Abstraction Layer)
 *
 *  Runnable period     : 10 ms  (driven by main scheduler)
 *
 *  Behaviour
 *  ---------
 *    Rising-edge of "SW1 pressed" signal →  toggle LED1 state
 *    (press once: LED on; press again: LED off)
 */
#include "SwcLedToggle.h"
#include "IoHwAb.h"

/* --------------------------------------------------------------------------
 * Module-internal state
 * -------------------------------------------------------------------------- */
typedef struct
{
    uint8   ledState;      /* IOHWAB_SIG_ACTIVE / INACTIVE                */
    uint8   prevSwState;   /* SW1 state sampled in the previous cycle      */
} SwcLedToggle_StateType;

static VAR(SwcLedToggle_StateType, SWC_VAR) SwcLedToggle_State =
{
    IOHWAB_SIG_INACTIVE,   /* ledState   – LED starts off                  */
    IOHWAB_SIG_INACTIVE    /* prevSwState – previous SW1 = released         */
};

/* --------------------------------------------------------------------------
 * SwcLedToggle_Run10ms
 * -------------------------------------------------------------------------- */
FUNC(void, SWC_CODE) SwcLedToggle_Run10ms(void)
{
    /* 1. Read current (debounced by polling period) SW1 state */
    uint8 currSwState = IoHwAb_Read_Sw1();

    /* 2. Detect rising edge: INACTIVE → ACTIVE */
    if ((currSwState   == IOHWAB_SIG_ACTIVE) &&
        (SwcLedToggle_State.prevSwState == IOHWAB_SIG_INACTIVE))
    {
        /* 3. Toggle LED */
        SwcLedToggle_State.ledState =
            (SwcLedToggle_State.ledState == IOHWAB_SIG_INACTIVE)
            ? IOHWAB_SIG_ACTIVE
            : IOHWAB_SIG_INACTIVE;

        IoHwAb_Write_Led1(SwcLedToggle_State.ledState);
    }

    /* 4. Save current SW1 state for next cycle */
    SwcLedToggle_State.prevSwState = currSwState;
}
