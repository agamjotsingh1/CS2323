.section .text

addi x5, x0, 125
addi x6, x0, 123 
beq x5, x6, _abc
addi x9, x0, 69
_abc: li x1, 16