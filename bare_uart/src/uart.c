#include "regs.h"
#include "uart.h"
#include "gpio.h"

#define APB_CLK_FREQ        80000000  // APB clock = 80 MHz

#define UART0_BASE          0x3FF40000
#define UART0_FIFO_REG       (volatile uint32_t*)(UART0_BASE + 0x0)
// #define UART_INT_RAW_REG  *(volatile uint32_t*)(UART0_BASE + 0x4)
// #define UART_INT_ST_REG     *(volatile uint32_t*)(UART0_BASE + 0x8)
#define UART0_INT_ENA_REG    (volatile uint32_t*)(UART0_BASE + 0xC)
#define UART0_INT_CLR_REG    (volatile uint32_t*)(UART0_BASE + 0x10)
#define UART0_CLKDIV_REG     (volatile uint32_t*)(UART0_BASE + 0x14)
#define UART0_AUTOBAUD_REG   (volatile uint32_t*)(UART0_BASE + 0x18)
#define UART0_STATUS_REG     (volatile uint32_t*)(UART0_BASE + 0x1C)
#define UART0_CONF0_REG      (volatile uint32_t*)(UART0_BASE + 0x20)
#define UART0_CONF1_REG      (volatile uint32_t*)(UART0_BASE + 0x24)
#define UART0_LOWPULSE_REG   (volatile uint32_t*)(UART0_BASE + 0x28)
#define UART0_HIGHPULSE_REG  (volatile uint32_t*)(UART0_BASE + 0x2c)
#define UART0_RXD_CNT_REG    (volatile uint32_t*)(UART0_BASE + 0x30)
#define UART0_FLOW_CONF_REG  (volatile uint32_t*)(UART0_BASE + 0x34)
#define UART0_SLEEP_CONF_REG (volatile uint32_t*)(UART0_BASE + 0x38)
#define UART0_SWFC_CONF_REG  (volatile uint32_t*)(UART0_BASE + 0x3c)
#define UART0_IDLE_CONF_REG  (volatile uint32_t*)(UART0_BASE + 0x40)

#define UART0_BAUD 115200
#define UART0_CLKDIV_INT(clk, baudrate)  (((clk) / baudrate) & 0x000FFFFF)
#define UART0_CLKDIV_FRAG(clk, baudrate) (((((clk % baudrate) * 16) / baudrate) & 0xF) << 20)
#define UART_GET_TX_SIZE(uart_mem_conf_reg) ((*uart_mem_conf_reg >> 7) & 0xF)
#define UART_GET_RX_SIZE(uart_mem_conf_reg) ((*uart_mem_conf_reg >> 3) & 0xF)
#define UART_GET_RX_COUNT(uart_status_reg)  (*uart_status_reg & 0xFF)
#define UART_GET_TX_COUNT(uart_status_reg)  ((*uart_status_reg >> 16) & 0xFF)

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
    *UART0_INT_ENA_REG = 0;

    // Disable AUTOBAUD
    REG_BIT_CLEAR(UART0_AUTOBAUD_REG, 0);

    // Configure UART0 CONF REG
    *UART0_CONF0_REG = 0;
    REG_BIT_SET(UART0_CONF0_REG, 27);        // Select APB Clock (80Mhz)
    REG_BIT_SET(UART0_CONF0_REG, 4);         // Set length of stop bit to 1
    *UART0_CONF0_REG |= (3 << 2);            // Set length of message (3 = 8bits), starting at bit 2
    REG_BIT_CLEAR(UART0_CONF0_REG, 23);      // Disable Receive-timeout function

    // Set CLKDIV
    // *UART0_CLKDIV_REG = UART0_CLKDIV_INT(APB_CLK_FREQ, UART0_BAUD) | UART0_CLKDIV_FRAG(APB_CLK_FREQ, UART0_BAUD);

    REG_BIT_SET(UART0_CONF0_REG, 18);        // Reset the UART transmit-FIFO
    REG_BIT_SET(UART0_CONF0_REG, 17);        // Reset the UART receive-FIFO
}

extern volatile uint32_t* gpio_out_w1ts_reg;

inline void uart0_write_byte(char c) {
    // wait until a byte is available
    while ((128u - UART_GET_TX_COUNT(UART0_STATUS_REG) < 2) | (*UART0_STATUS_REG & (0xFF << 16))) {};
    *UART0_FIFO_REG = (uint8_t)c;
}

inline void uart0_write_str(const char* s) {
    while (*s) uart0_write_byte(*s++);
}