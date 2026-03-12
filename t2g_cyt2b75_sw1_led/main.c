#include "cyhal.h"
#include "cybsp.h"

#define SW1_PIN        (P7_0)
#define LED1_PIN       (P19_0)
#define POLL_PERIOD_MS (10u)

static void handle_error(cy_rslt_t status)
{
    if (status != CY_RSLT_SUCCESS)
    {
        CY_ASSERT(0);
    }
}

int main(void)
{
    cy_rslt_t result;
    uint32_t prev_sw_state = 1u;
    uint32_t led_state = 1u;

    result = cybsp_init();
    handle_error(result);

    /* Active-low LED on P19.0: initial HIGH = off */
    result = cyhal_gpio_init(LED1_PIN,
                             CYHAL_GPIO_DIR_OUTPUT,
                             CYHAL_GPIO_DRIVE_STRONG,
                             1u);
    handle_error(result);

    /* Active-low button on P7.0: pull-up, LOW when pressed */
    result = cyhal_gpio_init(SW1_PIN,
                             CYHAL_GPIO_DIR_INPUT,
                             CYHAL_GPIO_DRIVE_PULLUP,
                             1u);
    handle_error(result);

    for (;;)
    {
        uint32_t curr_sw_state = cyhal_gpio_read(SW1_PIN);

        if ((curr_sw_state == 0u) && (prev_sw_state == 1u))
        {
            led_state = (led_state == 1u) ? 0u : 1u;
            cyhal_gpio_write(LED1_PIN, led_state);
        }

        prev_sw_state = curr_sw_state;
        cyhal_system_delay_ms(POLL_PERIOD_MS);
    }
}
