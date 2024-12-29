.section .text
.globl _start
_start:
    pushl %ebp
    push $5
    popl %ebp
    ret