# RT-Thread 实验
本目录用于学习 RT-Thread 源码，从零开始重写一遍 RT-Thread nano 内核，并且移植到本 cpu 上运行，基于野火《RT-Thread 内核实现与应用开发实战—基于STM32》，书籍的 pdf 在 doc 目录下。目前正在实时更新中~

目录结构：
1.  include：公共头文件目录；
2.  lib：公共函数目录；
3.  experiment1_thread：RT-Thread 实验 1，对应书籍第一部分《第6章 线程的定义与线程切换的实现》；
4.  start.S：启动文件，进行初始化以及数据的搬运；
5.  link.lds：链接脚本；
6.  common.mk：Makefile 的公共部分；

## 1. experiment1_thread（线程的定义与线程切换的实现）
目录结构：
1.  rtthread-nano：源码目录，附带注释，与官方源码一起食用更佳；
2.  user：用户程序目录，定义用户线程；
3.  Makefile：编译脚本，执行 make 或 make clean；
4.  rtthread.bin：二进制程序，可以用 serial_utils 目录下的烧录工具烧录到 cpu 中；
5.  rtthread.dump：反汇编结果；

实验现象：
用串口工具连上开发板，打开串口，按下复位键后，可以看到两个线程轮流打印信息：
```
Thread 1 running...
Thread 2 running...
Thread 1 running...
Thread 2 running...
...
```