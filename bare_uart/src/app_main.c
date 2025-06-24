#include "regs.h"
#include "uart.h"
#include "gpio.h"

// volatile uint32_t* gpio_enable_reg = (uint32_t*)GPIO_ENABLE_REG;
// volatile uint32_t* gpio_out_w1ts_reg = (uint32_t*)GPIO_OUT_W1TS_REG;
// volatile uint32_t* gpio_out_w1tc_reg = (uint32_t*)GPIO_OUT_W1TC_REG;

#define LED_PIN 2

extern void delay_cycles(volatile uint32_t cycles);

void loop_led() {
    while (1) {
        gpio_clear(LED_PIN);
        delay_cycles(100000);

        gpio_set(LED_PIN);
        delay_cycles(100000);
    }
}

const char my_string[] = "Hello from the new memory map\n";

void test_memory() {
    gpio_set(LED_PIN);
    delay_cycles(1000000);

    if (my_string[1] == 'e') {
        loop_led();
    }
}

void test_uart() {
    gpio_set(LED_PIN);
    delay_cycles(10000000);

    while (1) {
        gpio_clear(LED_PIN);
        delay_cycles(1000000);

        uart0_write_str(my_string);

        gpio_set(LED_PIN);
        delay_cycles(1000000);
    }
}


int app_main() {
    gpio_enable(LED_PIN);

    // test_flash();
    // test_memory();
    // uart0_init();

    test_uart();

    while (1) {};
}