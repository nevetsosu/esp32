#pragma once
#include <stdint.h>

#define UART0_BASE          0x3FF40000
#define UART1_BASE          0x3FF50000
#define UART2_BASE          0x3FF6E000

typedef struct uart_regs_t {
    volatile uint32_t FIFO;
    volatile uint32_t INT_RAW;
    volatile uint32_t INT_ST;
    volatile uint32_t INT_ENA;
    volatile uint32_t INT_CLR;
    volatile uint32_t CLKDIV;
    volatile uint32_t AUTOBAUD;
    volatile uint32_t STATUS;
    volatile uint32_t CONF0;
    volatile uint32_t CONF1;
    volatile uint32_t LOWPULSE;
    volatile uint32_t HIGHPULSE;
    volatile uint32_t RXD_CNT;
    volatile uint32_t FLOW_CONF;
    volatile uint32_t SLEEP_CONF;
    volatile uint32_t SWFC_CONF;
    volatile uint32_t IDLE_CONF;
    volatile uint32_t RS485_CONF;
    volatile uint32_t AT_CMD_PRECNT;
    volatile uint32_t AT_CMD_POSTCNT;
    volatile uint32_t AT_CMD_GAPTOUT;
    volatile uint32_t AT_CMD_CHAR;
    volatile uint32_t MEM_CONF;
    volatile uint32_t MEM_TX_STATUS;
    volatile uint32_t MEM_RX_STATUS;
    volatile uint32_t MEM_CNT_STATUS;
    volatile uint32_t POSPULSE;
    volatile uint32_t NEGPULSE;
} uart_regs_t;

#define UART0       ((uart_regs_t*)(0x3FF40000))
#define UART1       ((uart_regs_t*)(0x3FF50000))
#define UART2       ((uart_regs_t*)(0x3FF6E000))

void uart0_init();
void uart0_write_str(const char* s);
void uart0_write_byte(char c);
void uart0_write_str_n(const char* s, uint32_t n);

inline uint32_t UART_CLKDIV_INT(uint32_t clk, uint32_t baudrate) {
    return (clk / baudrate) & 0x000FFFFF;
}

inline uint32_t UART_CLKDIV_FRAG(uint32_t clk, uint32_t baudrate) {
    return ((((clk % baudrate) * 16) / baudrate) & 0xF) << 20;
}

inline uint32_t UART_GET_TX_SIZE(uart_regs_t* uart) {
    return ((uart->MEM_CONF >> 7) & 0xF);
}

inline uint32_t UART_GET_RX_SIZE(uart_regs_t* uart) {
    return ((uart->MEM_CONF >> 3) & 0xF);
}

inline uint32_t UART_GET_RX_COUNT(uart_regs_t* uart) {
    return (uart->STATUS & 0xFF);
}

inline uint32_t UART_GET_TX_COUNT(uart_regs_t* uart) {
    return ((uart->STATUS >> 16) & 0xFF);
}