#include "gpio.h"

void gpio_enable(uint32_t pin) {
    *GPIO_ENABLE_REG |= (1 << pin);
}

void gpio_set(uint32_t pin) {
    *GPIO_OUT_W1TS_REG = (1 << pin);
}

void gpio_clear(uint32_t pin) {
    *GPIO_OUT_W1TC_REG = (1 << pin);
}