// #define UART_FIFO_REG         (volatile uint32_t*)0x3FF40000
// #define UART_STATUS_REG       (volatile uint32_t*)0x3FF4001C
// #define UART_CLKDIV_REG       (volatile uint32_t*)0x3FF40014
// #define UART_CONF0_REG        (volatile uint32_t*)0x3FF40020
#pragma once

void uart0_init();
void uart0_write_str(const char* s);
void uart0_write_byte(char c);
