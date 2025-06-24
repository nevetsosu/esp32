#pragma once
#include <stdint.h>

// IOMUX
#define IO_MUX_U0RXD_REG (volatile uint32_t*)(0x3FF49084)
#define IO_MUX_U0TXD_REG (volatile uint32_t*)(0x3FF49088)

#define REG_BIT_SET(x, y) (*x |= (1 << y))
#define REG_BIT_CLEAR(x, y) (*x &= ~(1 << y))
