#include "uart.h"
#include "regs.h"
#include "gpio.h"

#define APB_CLK_FREQ        80000000  // APB clock = 80 MHz

#define UART0_BAUD 115200 // default baud

static inline void conf_uart0_gpio() {
    *IO_MUX_U0RXD_REG &= ~(0x7 << 12);  // Connect UART to U0RXD pin
    *IO_MUX_U0TXD_REG &= ~(0x7 << 12);  // Connect UART to U0TXD pin

    // ensure pin 1 and 3 are set
    *GPIO_ENABLE_REG |= (1 << 1);
    *GPIO_ENABLE_REG |= (1 << 3);

    *GPIO_OUT_W1TS_REG = (1 << 1);
    *GPIO_OUT_W1TC_REG = (1 << 3);
}

inline void uart0_init() {
    // conf uart gpio
    conf_uart0_gpio();

    // Disable interrupts for now
    UART0->INT_ENA = 0;

    // Disable AUTOBAUD
    UART0->AUTOBAUD &= ~1;
    // Set CLKDIV

    // TODO Fix the CLKDIV calculation
    // UART0->CLKDIV = UART_CLKDIV_INT(APB_CLK_FREQ, UART0_BAUD) | UART_CLKDIV_FRAG(APB_CLK_FREQ, UART0_BAUD);

    // Configure UART0 CONF REG
    if (&UART0->CONF0 != (void*)(UART0_BASE + 0x20)) {
        while(1) {}
    }

    uint32_t conf0 = 0;
    conf0 |= (1 << 27);         // Select APB Clock (80Mhz)
    conf0 |= (1 << 4);          // Set length of stop bit to 1
    conf0 |= (3 << 2);          // Set length of message (3 = 8bits), starting at bit 2
    conf0 &= ~(1 << 23);        // Disable Receive-timeout function
    UART0->CONF0 = conf0;

    // Reset the UART transmit-FIFO and receive-FIFO
    conf0 |= (3 << 17);
    UART0->CONF0 = conf0;
    // clear the reset bits on another write
    conf0 &= ~(3 << 17);
    UART0->CONF0 = conf0;
}

extern volatile uint32_t* gpio_out_w1ts_reg;

inline void uart0_write_byte(char c) {
    // wait until a byte is available
    // (128u - UART_GET_TX_COUNT(UART0) < 2) |
    while ((UART0->STATUS & (0xFF << 16))) {};
    UART0->FIFO = (uint8_t)c;
}

inline void uart0_write_str(const char* s) {
    while (*s) uart0_write_byte(*s++);
}

inline void uart0_write_str_n(const char* s, uint32_t n) {
    while (n--) uart0_write_byte(*s++);
}