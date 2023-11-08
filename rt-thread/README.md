# RT-Thread 实验
本目录用于学习 RT-Thread 源码，从零开始重写一遍 RT-Thread nano 内核，并且移植到本 cpu 上运行，基于**野火《RT-Thread 内核实现与应用开发实战—基于STM32》**，书籍的 pdf 在 doc 目录下。目前已经开发完毕~

## 目录结构
1.  include：公共头文件目录；
2.  lib：公共函数目录；
3.  start.S：启动文件；
4.  link.lds：链接脚本；
5.  common.mk：Makefile 的公共部分（Windows 平台下）；
6.  common_ubuntu.mk：Makefile 的公共部分（Ubuntu 平台下）；
7.  demo：用户可以在本目录下编写能在本 CPU 上运行的 C 程序；
8.  experiment1_thread：实验 1，对应书籍第一部分《第6章 线程的定义与线程切换的实现》；
9.  experiment2_container：实验 2，对应《第7章 临界段的保护》《第8章 对象容器的实现》两章；
10. experiment3_delay：实验 3，对应《第9章 空闲线程与阻塞延时的实现》
11. experiment4_muti_priority：实验 4，对应《第10章 多优先级》
12. experiment5_timer：实验 5，对应《第11章 定时器的实现》
13. experiment6_timeslice：实验6，对应《第12章 支持时间片》
14. experiment7_finsh：实验7，自己移植的 Finsh 组件

## 编译环境
### Windows 平台下环境搭建
1. GNU 工具链（链接：https://pan.baidu.com/s/1Bdmn-FH0T7ekm2kMxkzJTw?pwd=qn69 提取码：qn69），百度云下载解压后，将 bin 目录添加到环境变量里即可。
2. make 工具（链接：https://pan.baidu.com/s/1X-F1BVPMa3-B-V1EHB4tEQ?pwd=418d 提取码：418d），百度云下载解压后，将 bin 目录添加到环境变量里即可。
3. Python 3.7

### Ubuntu 平台下环境搭建
Ubuntu 版本：
```
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.2 LTS
Release:	20.04
Codename:	focal
 
$ uname -r
5.15.0-76-generic
```
安装Ubuntu 20.04官方提供的 GNU工具链：

```
sudo apt update
sudo apt install build-essential gcc make perl dkms git gcc-riscv64-unknown-elf
```
并且要将 Makefile 里面的 ```include ../common.mk``` 修改为 ```include ../common_ubuntu.mk```。
## 使用说明

进入到指定目录下（如 experiment1_thread 目录），执行如下命令：
```
make
``` 
编译工程后会生成二进制程序 rtthread.bin，以及 16 进制指令序列文件 rtthread.inst（在 rt-thread 目录下），用前面介绍的两种方法来运行程序，通过串口工具（**波特率为 19200**）即可看到现象。可以使用生成的 rtthread.dump 文件来查看程序的汇编指令。

使用如下命令来清除生成的文件。
```
make clean
```

**注：目前 experiment1_thread 与 experiment2_container 只能用前面介绍的第一种方法来运行，即直接作为 FPGA 比特流的一部分下载到板子上。其他的实验使用前面的两种方法都是没问题的。**

## demo 目录
本目录可以供用户在 main.c 文件中编写自己的 C 程序。

使用方法和其他 experiment 目录一样，使用 make 命令编译生成 demo.bin 和 demo.inst 文件，再利用前面介绍的方法运行程序即可。

默认的 main.c 代码为一个简单的加法操作：
```
int main(void)
{
    int a = 1;
    int b = 2;
    int c = a + b;
    printf("The result of c: %d\n", c);

    /* stop here */
    while(1){};
}
```
烧录后使用串口看到的现象为：
```
The result of c: 3
```

## 1. experiment1_thread（线程的定义与线程切换的实现）
**目录结构**：
1.  rtthread-nano：源码目录，附带注释，与官方源码一起食用更佳；
2.  user：用户程序目录，定义用户线程；
3.  Makefile：编译脚本，执行 make 或 make clean；

**实验现象**：
用串口工具连上开发板，打开串口，按下复位键后，可以看到两个线程轮流打印信息：
```
Thread 1 running...
Thread 2 running...
Thread 1 running...
Thread 2 running...
...
```
## 2. experiment2_container（临界段的保护，对象容器的实现）
**实验现象**：
用串口工具连上开发板，打开串口，按下复位键后，可以看到线程1会打印所有的线程对象信息：
```
Thread 1 running...
the name of thread object: thread2
the type of thread object: 129
the flag of thread object: 0
the name of thread object: thread1
the type of thread object: 129
the flag of thread object: 0
Thread 2 running...
...
```
## 3. experiment3_delay（空闲线程与阻塞延时的实现）
**实验现象**：
用串口工具连上开发板，打开串口，按下复位键后，可以看到在线程1和线程2阻塞延时后，空闲线程开始执行，5个 tick 后，线程1和2重新开始执行：
```
Thread 1 running...
the thread1 tick before is 0
Thread 2 running...
the thread2 tick before is 0
The idle thread is running...
The idle thread is running...
the thread1 tick after is 5
...
```
## 4. experiment4_muti_priority（多优先级）
**实验现象**：
用串口工具连上开发板，打开串口，按下复位键后，可以看到线程1会一直执行（线程1的优先级比线程2高），直到线程1阻塞后，线程2才会出来执行：
```
Thread 1 running...
Thread 1 running...
Thread 1 running...
Thread 1 running...
Thread 1 running...
the thread1 tick before is 4
Thread 2 running...
Thread 2 running...
Thread 2 running...
the thread1 tick after is 9
...
```
## 5. experiment5_timer（定时器的实现）
**实验现象**：
用串口工具连上开发板，打开串口，按下复位键后，可以看到线程1会先执行，然后延时5个 tick，其次是线程2执行，然后延时2个 tick，最后是线程3执行：
```
Thread 1 running...
the thread1 tick before is 0
Thread 2 running...
the thread2 tick before is 0
Thread 3 running...
Thread 3 running...
the thread2 tick after is 2
Thread 2 running...
the thread2 tick before is 2
Thread 3 running...
Thread 3 running...
the thread2 tick after is 4
Thread 2 running...
the thread2 tick before is 4
Thread 3 running...
the thread1 tick after is 5
Thread 1 running...
...
```
## 6. experiment6_timeslice（支持时间片）
**实验现象**：
用串口工具连上开发板，打开串口，按下复位键后，可以看到因为引入了时间片，三个线程会轮流执行：
```
Thread 1 running...
Thread 2 running...
Thread 3 running...
Thread 1 running...
Thread 2 running...
Thread 3 running...
...
```

## 7. experiment7_finsh（Finsh 组件）
**实验现象**：
使用 MobaXterm 或者 XShell 等工具连接串口，按下复位键后可以看到显示如下信息：
```
Welcome to RT-Thread's World!
msh >
```
输入 list 命令列出当前支持的所有命令：
```
msh >list
--Function List:
hello: say hello world
list: list all command
list_thread: list all thread
```
输入 hello 命令可以打印一行信息：
```
msh >hello
Hello RT-Thread!
```
输入 list_thread 命令会打印当前操作系统所运行的所有线程信息：
```
msh >list_thread
name       pri   status       sp       stack size   used   left tick   error
--------   ---   ------   ----------   ----------   ----   ---------   -----
thread2     6    ready    0x100012d0      512B      164B       1        0
thread1     6    ready    0x100010d0      512B      164B       1        0
tshell      6    ready    0x10000570      1024B      540B       7        0
tidle       7    ready    0x10000130      256B      128B       32        0
```
并且在 cmd.c 文件内支持自定义命令！