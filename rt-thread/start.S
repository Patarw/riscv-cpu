.section .init;
.globl _start;
.type _start, @function

_start:
.option push
.option norelax
    la gp, __global_pointer$
.option pop
    la sp, _sp

    /* 把 data section 从 flash 搬运到 ram 中 */
    la a0, _data_lma
    la a1, _data
    la a2, _edata
    bgeu a1, a2, 2f
1:
    lw t0, (a0)      /* 从 flash 中取出一个 word 的数据 */
    sw t0, (a1)      /* 将取出的数据存入 ram 中对应位置 */
    addi a0, a0, 4
    addi a1, a1, 4
    bltu a1, a2, 1b
2:
    /* 将 bss section 初始化为 0 */
    la a0, __bss_start
    la a1, _end
    bgeu a0, a1, 2f
1:
    sw zero, (a0)
    addi a0, a0, 4
    bltu a0, a1, 1b
2:

    /* 调用初始化函数 */
    call _init
    /* 跳转到 main */
    call main

/* never came here */
loop:
    j loop