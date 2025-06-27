#include <stdint.h>
#include "uart.h"

void delay(volatile uint32_t cycles) {
    while (cycles--) {
        __asm__ __volatile__("nop");
    }
}

void printh(uint32_t n) {
    uart0_write_str("0x");
    for (uint32_t i = 3; i < 32; i+=4) {
        if (!(i % 16)) {
            uart0_write_byte('_');
        }
        char c;
        switch ((n >> (31 - i)) & 0xF) {
            case 0x0:
                c = '0';
                break;
            case 0x1:
                c = '1';
                break;
            case 0x2:
                c = '2';
                break;
            case 0x3:
                c = '3';
                break;
            case 0x4:
                c = '4';
                break;
            case 0x5:
                c = '5';
                break;
            case 0x6:
                c = '6';
                break;
            case 0x7:
                c = '7';
                break;
            case 0x8:
                c = '8';
                break;
            case 0x9:
                c = '9';
                break;
            case 0xa:
                c = 'a';
                break;
            case 0xb:
                c = 'b';
                break;
            case 0xc:
                c = 'c';
                break;
            case 0xd:
                c = 'd';
                break;
            case 0xe:
                c = 'e';
                break;
            case 0xf:
                c = 'f';
                break;
            default:
                c = 'L';
        }
        uart0_write_byte(c);
    }
    uart0_write_byte('\n');
}

void printb(uint32_t n) {
    uart0_write_str("0b");
    for (uint32_t i = 0; i < 32; i++) {
        if (!(i % 4)) {
            uart0_write_byte('_');
        }
        uart0_write_byte('0' + !!(n & (1 << (31 - i))));

    }
    uart0_write_byte('\n');
}