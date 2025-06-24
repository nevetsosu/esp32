#include <stdint.h>
#include "regs.h"

extern void disable_watchdogs();
extern void uart0_init();
extern int app_main(void);

void boot() {
    disable_watchdogs();
    uart0_init();
    app_main();
}