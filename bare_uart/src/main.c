#include <stdint.h>
#include "regs.h"

extern void disable_watchdogs();
extern int app_main(void);

void boot() {
    disable_watchdogs();

    app_main();
}