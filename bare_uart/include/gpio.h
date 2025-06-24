#pragma once
#include <stdint.h>

#define GPIO_OUT_W1TS_REG   (volatile uint32_t*)(0x3FF44008)
#define GPIO_OUT_W1TC_REG   (volatile uint32_t*)(0x3FF4400C)
#define GPIO_ENABLE_REG     (volatile uint32_t*)(0x3FF44020)

void gpio_enable(uint32_t pin);
void gpio_set(uint32_t pin);
void gpio_clear(uint32_t pin);