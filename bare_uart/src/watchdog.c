#include <stdint.h>

// For disabling watchdog timers
#define TIMG0_WDTCONFIG0_REG (volatile uint32_t*)(0x3FF5F048)
#define RTC_CNTL_WDTCONFIG0_REG  (volatile uint32_t*)(0x3FF4808C)

void disable_watchdogs() {
    *TIMG0_WDTCONFIG0_REG = 0;
    *RTC_CNTL_WDTCONFIG0_REG = 0;
}