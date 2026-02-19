#include <stdint.h>

volatile uint32_t g_heartbeat = 0u;

int main(void)
{
    while (1)
    {
        g_heartbeat++;
    }
}
