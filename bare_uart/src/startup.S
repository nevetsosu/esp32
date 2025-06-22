.section .entry.text
.global _start

_start:
    call8 boot
_start_spinloop:
    j _start_spinloop