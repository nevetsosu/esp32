#include <stdint.h>
#include "regs.h"

extern void disable_watchdogs();
extern void init_flash();
extern void uart0_init();
extern int app_main(void);

void boot() {
    
    disable_watchdogs();
    // init_flash();
    app_main();
}