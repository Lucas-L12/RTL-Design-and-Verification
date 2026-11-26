    .section .text.init, "ax", @progbits
    .globl _start

_start:
    call main

halt:
    j halt