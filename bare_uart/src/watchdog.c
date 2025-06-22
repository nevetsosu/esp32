#include "regs.h"
#include <stdint.h>

static volatile uint32_t* timg0_wdt = (uint32_t*)TIMG0_WDTCONFIG0_REG;
static volatile uint32_t* rtc_wdt  = (uint32_t*)RTC_CNTL_WDTCONFIG0_REG;

void disable_watchdogs() {
    *timg0_wdt = 0;
    *rtc_wdt   = 0;
}