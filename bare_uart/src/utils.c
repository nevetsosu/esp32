#include <stdint.h>

void delay_cycles(volatile uint32_t cycles) {
    while (cycles--) {
        __asm__ __volatile__("nop");
    }
}