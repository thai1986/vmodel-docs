#include <stdint.h>

extern int main(void);

extern uint32_t _sidata;
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _sbss;
extern uint32_t _ebss;
extern uint32_t _estack;

void Reset_Handler(void);
void Default_Handler(void);

void NMI_Handler(void)          __attribute__((weak, alias("Default_Handler")));
void HardFault_Handler(void)    __attribute__((weak, alias("Default_Handler")));
void MemManage_Handler(void)    __attribute__((weak, alias("Default_Handler")));
void BusFault_Handler(void)     __attribute__((weak, alias("Default_Handler")));
void UsageFault_Handler(void)   __attribute__((weak, alias("Default_Handler")));
void SVC_Handler(void)          __attribute__((weak, alias("Default_Handler")));
void DebugMon_Handler(void)     __attribute__((weak, alias("Default_Handler")));
void PendSV_Handler(void)       __attribute__((weak, alias("Default_Handler")));
void SysTick_Handler(void)      __attribute__((weak, alias("Default_Handler")));

__attribute__((section(".isr_vector")))
const void * const g_pfnVectors[256] =
{
    (void *)&_estack,
    (void *)Reset_Handler,
    (void *)NMI_Handler,
    (void *)HardFault_Handler,
    (void *)MemManage_Handler,
    (void *)BusFault_Handler,
    (void *)UsageFault_Handler,
    0,
    0,
    0,
    0,
    (void *)SVC_Handler,
    (void *)DebugMon_Handler,
    0,
    (void *)PendSV_Handler,
    (void *)SysTick_Handler,

    /* External IRQ vectors default to safe trap handler. */
    [16 ... 255] = (void *)Default_Handler
};

void Reset_Handler(void)
{
    uint32_t *src = &_sidata;
    uint32_t *dst = &_sdata;

    while (dst < &_edata)
    {
        *dst++ = *src++;
    }

    dst = &_sbss;
    while (dst < &_ebss)
    {
        *dst++ = 0u;
    }

    (void)main();

    while (1)
    {
        /* main should not return */
    }
}

void Default_Handler(void)
{
    while (1)
    {
        /* Trap unexpected interrupts in a safe infinite loop */
    }
}
