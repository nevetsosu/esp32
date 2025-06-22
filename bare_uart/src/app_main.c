#include "regs.h"
#include <stdint.h>

static volatile uint32_t* gpio_enable_reg = (uint32_t*)GPIO_ENABLE_REG;
static volatile uint32_t* gpio_out_w1ts_reg = (uint32_t*)GPIO_OUT_W1TS_REG;
static volatile uint32_t* gpio_out_w1tc_reg = (uint32_t*)GPIO_OUT_W1TC_REG;

#define GPIO_PIN 2

extern void delay_cycles(volatile uint32_t cycles);

int app_main() {
    // enable GPIO PIN
    *gpio_enable_reg = (1 << GPIO_PIN);

    // TURN ON
    *gpio_out_w1ts_reg = (1 << GPIO_PIN);
    delay_cycles(10000000);

    while (1) {
        // turn off
        *gpio_out_w1tc_reg = (1 << GPIO_PIN);
        delay_cycles(1000000);

        // TURN ON
        *gpio_out_w1ts_reg = (1 << GPIO_PIN);
        delay_cycles(1000000);

    }
}