#include "uart.h"
__attribute__((section(".WindowVectors.text")))
void WindowVectors() {
    while (1) {
        uart0_write_str("WindowVectors");
    }
}

__attribute__((section(".Level2InterruptVector.text")))
void Level2InterruptVector() {
    while (1) {
        uart0_write_str("Level2InterruptVector");
    }
}

__attribute__((section(".Level3InterruptVector.text")))
void Level3InterruptVector() {
    while (1) {
        uart0_write_str("Level3InterruptVector");
    }
}

__attribute__((section(".Level4InterruptVector.text")))
void Level4InterruptVector() {
    while (1) {
        uart0_write_str("Level4InterruptVector");
    }
}

__attribute__((section(".Level5InterruptVector.text")))
void Level5InterruptVector() {
    while (1) {
        uart0_write_str("Level5InterruptVector");
    }
}

__attribute__((section(".DebugExceptionVector.text")))
void DebugExceptionVector() {
    while (1) {
        uart0_write_str("DebugExceptionVector");
    }
}

__attribute__((section(".NMIExceptionVector.text")))
void NMIExceptionVector() {
    while (1) {
        uart0_write_str("NMIExceptionVector");
    }
}

__attribute__((section(".KernelExceptionVector.text")))
void KernelExceptionVector() {
    while (1) {
        uart0_write_str("KernelExceptionVector");
    }
}

__attribute__((section(".UserExceptionVector.text")))
void UserExceptionVector() {
    while (1) {
        uart0_write_str("UserExceptionVector");
    }
}

__attribute__((section(".DoubleExceptionVector.text")))
void DoubleExceptionVector() {
    while (1) {
        uart0_write_str("DoubleExceptionVector");
    }
}