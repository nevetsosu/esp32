#include <stdint.h>
#include "uart.h"
#include "sys/reent.h"
#include <sys/stat.h>
extern void delay_cycles(uint32_t cycles);

// #include <errno.h>
// #undef errno

extern int errno;
int _kill(int pid, int sig) {
  errno = 0;
  return -1;
}

void _exit(int code) {
    while (1) {
        uart0_write_str("exited");
        delay_cycles(1000000);
    }
}

int _getpid(void) {
  return 1;
}

int _close(int file) {
  return -1;
}

int _write(uint32_t file, const char* ptr, int len) {
    (void) file;
    uart0_write_str_n(ptr, len);
    return len;
}

int _read(int file, char *ptr, int len) {
  return 0;
}

struct _reent * __getreent (void) {
    static struct _reent r = {0};
    return &r;
}

int _fstat(int file, struct stat *st) {
  return 0;
}

int _lseek(int file, int ptr, int dir) {
  return 0;
}

int puts(const char *s) {
    uart0_write_str(s);
    return 1;
}

void* _sbrk (int32_t incr) {
    extern uint8_t* _heap_end;
    static uint8_t* cur_heap_end;
    uint8_t* prev_heap_end;

    // get stack pointer
    uint8_t* sp;
    __asm__ volatile ("mov %0, sp" : "=r"(sp));

    // assign cur_heap_end if not initialized
    if (cur_heap_end == 0) {
        cur_heap_end = _heap_end;
    }

    // make sure this doesn't collide with stack
    prev_heap_end = cur_heap_end;
    if ((cur_heap_end + incr) > sp) {
        while (1) {
            uart0_write_str("heap collission with stack");
            delay_cycles(1000000);
        }
    }

    cur_heap_end += incr;
    return prev_heap_end;
}
