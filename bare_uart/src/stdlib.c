#include <stdint.h>
#include "uart.h"
// // #include "gpio.h"
// #include "sys/reent.h"
// #include <sys/stat.h>
// // #include <sys/times.h>
// // #include <errno.h>

extern void delay(uint32_t cycles);

// // for environ_
// static char *__env[1] = { 0 };
// char **environ = __env;

// struct _reent * __getreent (void) {
//     static struct _reent r = {0};
//     return &r;
// }

int _kill(int pid, int sig) {
    // errno = 0;
    return -1;
}

// int _unlink(char *name) {
//     errno = ENOENT;
//     return -1;
// }

// int _execve(char *name, char **argv, char **env) {
//     errno = ENOMEM;
//     return -1;
// }

// int _wait(int *status) {
//     errno = ECHILD;
//     return -1;
// }

// int _fork(void) {
//     errno = EAGAIN;
//     return -1;
// }

// int _link(char *old, char *new) {
//     errno = EMLINK;
//     return -1;
// }

// int _open(const char *name, int flags, int mode) {
//     return -1;
// }

void _exit(int code) {
    while (1) {
        uart0_write_str("exited");
        delay(1000000);
    }
}

int _getpid(void) {
    return 1;
}

int _close(int file) {
    return -1;
}

// int _close_r(struct _reent * ent, int file) {
//     return _close(file);
// }

int _write(uint32_t file, const char* ptr, int len) {
    // uart0_write_str("call to write");
    // uart0_write_str_n(ptr, len);
    extern void print();
    print(len);
    return len;
}

// int _write_r(struct _reent * ent, uint32_t file, const char* ptr, int len) {
//     return _write(file, ptr, len);
// }


int _read(int file, char *ptr, int len) {
    return 0;
}

// int _read_r(struct _reent * ent, int file, char *ptr, int len) {
//     return _read(file, ptr, len);
// }

// // int _stat(char *file, struct stat *st) {
// //     st->st_mode = S_IFCHR;
// //     return 0;
// // }

// // int _times(struct tms *buf) {
// //     return -1;
// // }

#include <sys/stat.h>
int _fstat(int file, struct stat *st) {
    st->st_mode = S_IFCHR;      // line buffered, this is a character device
    return 0;
}

// int _fstat_r(struct _reent * ent, int file, struct stat *st) {
//     return _fstat(file, st);
// }

int _lseek(int file, int ptr, int dir) {
    return 0;
}

// int _lseek_r(int file, int ptr, int dir) {
//     return _lseek(file, ptr, dir);
// }
// working
extern uint8_t* end;   // this should already be aligned to 8, from the linker script
void* _sbrk (int32_t incr) {
    static uint8_t* cur_heap_end = 0;

    // get stack pointer
    uint8_t* sp;
    __asm__ volatile ("mov %0, sp" : "=r"(sp));

    // assign cur_heap_end if not initialized
    if (cur_heap_end == 0) {
        cur_heap_end = end;
    }

    // make sure this doesn't collide with stack
    if ((cur_heap_end + incr) > sp) {
        while (1) {
            uart0_write_str("heap collission with stack");
            delay(1000000);
        }
    }

    uint8_t* prev_heap_end = cur_heap_end;
    cur_heap_end += incr;
    return prev_heap_end;
}

// void* _sbrk_r (struct _reent * ent, int32_t incr) {
//     (void) ent;
//     return _sbrk(incr);
// }

int _isatty(int file) {
    return 1;
}

// int pthread_setcancelstate(int state, int *oldstate) {
//     return 0;
// }
