#include <stdint.h>

#define GPIO_OUT_W1TS_REG  0x3FF44008
#define GPIO_OUT_W1TC_REG  0x3FF4400C
#define GPIO_ENABLE_REG 0x3FF44020

static volatile uint32_t* gpio_out_w1ts_reg = (uint32_t*)GPIO_OUT_W1TS_REG;
// static volatile uint32_t* gpio_out_w1tc_reg = (uint32_t*)GPIO_OUT_W1TC_REG;
static volatile uint32_t* gpio_enable_reg = (uint32_t*)GPIO_ENABLE_REG;
const uint32_t misc_value = 0xdeadbeef;
uint32_t misc_value2 = 0xdeadbeef;

#define GPIO_PIN 2

void boot() {
    if (misc_value == 0xdeadbeef) {
        // enable GPIO PIN
        *gpio_enable_reg = (1 << GPIO_PIN);

        // TURN ON
        *gpio_out_w1ts_reg = (1 << GPIO_PIN);
    }

    while (1) {};

    // turn off
    // *gpio_out_w1tc_reg = (1 << GPIO_PIN);
}

// // Startup logic; this is the application entry point.
// void __attribute__( ( noreturn ) ) _start() {
//     boot();
//     while(1) {};
// }