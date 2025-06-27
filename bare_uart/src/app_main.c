#include "regs.h"
#include "uart.h"
#include "gpio.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "utils.h"

// volatile uint32_t* gpio_enable_reg = (uint32_t*)GPIO_ENABLE_REG;
// volatile uint32_t* gpio_out_w1ts_reg = (uint32_t*)GPIO_OUT_W1TS_REG;
// volatile uint32_t* gpio_out_w1tc_reg = (uint32_t*)GPIO_OUT_W1TC_REG;

#define LED_PIN 2

void loop_led() {
    while (1) {
        gpio_clear(LED_PIN);
        delay(100000);

        gpio_set(LED_PIN);
            delay(100000);
    }
}

const char* my_string[] = {
    "Hello from the new memory map\n",
    "Test 2 string\n",
    "High low let slow\n"
};

void test_memory() {
    gpio_set(LED_PIN);
    delay(1000000);

    if (my_string[0][1] == 'e') {
        loop_led();
    }
}

void test_printf() {
    while (1) {
        gpio_clear(LED_PIN);
        delay(1000000);

        printf("0123456789");

        gpio_set(LED_PIN);
        delay(1000000);
    }
}

void test_malloc() {
    gpio_set(LED_PIN);
    delay(2000000);

    while (1) {
        gpio_clear(LED_PIN);
        delay(1000000);
        uart0_write_str("malloc and free\n");

        free(malloc(0x1000));

        gpio_set(LED_PIN);
        delay(1000000);
    }

}

void test_uart() {
    gpio_set(LED_PIN);
    delay(10000000);

    uint32_t count = 0;
    while (1) {
        gpio_clear(LED_PIN);
        delay(2000000);

        uart0_write_str(my_string[count++ % 3]);

        gpio_set(LED_PIN);
        delay(2000000);
    }
}

#include <stdlib.h>
int app_main() {
    gpio_enable(LED_PIN);

    // test_flash();
    // test_memory();

    // test_uart();
    while (1) {
        uart0_write_str("ACTUAL CLKDIV hex: ");
        printh(UART0->CLKDIV);

        uart0_write_str("set baud CLKDIV hex: ");
        printh(UART_CLKDIV_INT(APB_CLK_FREQ, UART0_BAUD) | UART_CLKDIV_FRAG(APB_CLK_FREQ, UART0_BAUD));

        uart0_write_str("230400 CLKDIV hex: ");
        printh(UART_CLKDIV_INT(APB_CLK_FREQ, 230400) | UART_CLKDIV_FRAG(APB_CLK_FREQ, 230400));

        uart0_write_str("CONF0 bin: ");
        printb(UART0->CONF0);

        delay(10000000);
    }
    // test_printf();
    // test_malloc();

    while (1) {};
}