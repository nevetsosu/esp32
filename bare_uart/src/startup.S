.extern _heap_end

.align 4
.section .entry.literal
_stack_start:
    .word _heap_end

.section .entry.text
.global _start

_start:
    l32r    sp, _stack_start
    call8   boot
_start_spinloop:
    j   _start_spinloop

