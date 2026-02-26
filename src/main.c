/**
 * @file    main.c
 * @brief   OS entry point / 10 ms scheduler loop
 *
 * AUTOSAR layer map
 * -----------------
 *   [App]    SwcLedToggle          src/App/SwcLedToggle/
 *   [EcuAb]  IoHwAb                src/EcuAb/IoHwAb/
 *   [MCAL]   Port, Dio             src/Mcal/Port/  src/Mcal/Dio/
 *   [Base]   Std_Types, Platform   src/
 *
 * Board : CYTVII-B-E-1M-SK  (CYT2B75XX, Arm Cortex-M4F)
 * Cycle : 10 ms polling scheduler (replace with OS alarm in production)
 */

#include "Std_Types.h"
#include "Port.h"
#include "SwcLedToggle.h"

/* --------------------------------------------------------------------------
 * Minimal busy-wait tick  (~10 ms @ ~48 MHz Cortex-M4F)
 * Replace with SysTick / OS alarm counter in a full AUTOSAR OS integration.
 * -------------------------------------------------------------------------- */
static FUNC(void, OS_CODE) Os_WaitTick10ms(void)
{
    volatile uint32 n = 480000UL;   /* ~10 ms at 48 MHz, 1 cycle/iter     */
    while (n > 0u) { n--; }
}

/* --------------------------------------------------------------------------
 * main - ECU start-up sequence + 10 ms scheduler loop
 *
 * AUTOSAR start-up phases (simplified, no OS / BswM / EcuM here):
 *   Phase 1 - Hardware initialisation  : Port_Init()
 *   Phase 2 - Scheduler loop           : call runnables at their periods
 * -------------------------------------------------------------------------- */
int main(void)
{
    /* ------------------------------------------------------------------
     * Phase 1: MCAL initialisation
     * ------------------------------------------------------------------ */
    Port_Init();   /* Configure all GPIO pins (SW1 pull-up, LED1 output)  */

    /* ------------------------------------------------------------------
     * Phase 2: 10 ms scheduler loop
     *          (In production: replace with AUTOSAR OS alarm + task)
     * ------------------------------------------------------------------ */
    while (1)
    {
        Os_WaitTick10ms();          /* Wait one 10 ms tick                */
        SwcLedToggle_Run10ms();     /* Application SWC runnable           */
    }
}
