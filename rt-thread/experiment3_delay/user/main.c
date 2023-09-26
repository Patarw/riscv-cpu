/* 头文件声明 */
#include <rtthread.h>
#include <rthw.h>
#include "include/rtconfig.h"
#include "../../include/printf.h"
#include "../../include/uart.h"
#include "../../include/hw_timer.h"

/* 线程优先级链表 */
extern rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];

/* 线程控制块定义 */
struct rt_thread rt_thread1;
struct rt_thread rt_thread2;

ALIGN(RT_ALIGN_SIZE)
/* 定义线程栈 */
rt_uint8_t rt_thread1_stack[512];
rt_uint8_t rt_thread2_stack[512];

/* 线程声明 */
void thread_1_entry(void *p_arg);
void thread_2_entry(void *p_arg);

/* 函数声明 */
void delay(unsigned int count);

/* main 函数 */
int main(void)
{
    /* 硬件初始化 */
    rt_hw_interrupt_disable(); /* 关中断 */
    uart_init();               /* 初始化串口 */
    hw_timer_init();           /* 初始化硬件定时器 */


    /* 调度器初始化 */
    rt_system_scheduler_init();

    /* 初始化空闲线程 */
    rt_thread_idle_init();

    /* 初始化线程 */
    rt_thread_init(&rt_thread1,               /* 线程控制块 */
                   "thread1",                 /* 线程名称，唯一 */
                   thread_1_entry,            /* 线程入口地址 */
                   RT_NULL,                   /* 线程形参 */
                   &rt_thread1_stack[0],      /* 线程栈起始地址 */
                   sizeof(rt_thread1_stack),
                   0); /* 线程栈大小 */
    /* 将线程插入就绪列表 */
    rt_list_insert_before(&(rt_thread_priority_table[0]), &(rt_thread1.tlist));

    /* 初始化线程 */
    rt_thread_init(&rt_thread2,               /* 线程控制块 */
                   "thread2",                 /* 线程名称，唯一 */
                   thread_2_entry,            /* 线程入口地址 */
                   RT_NULL,                   /* 线程形参 */
                   &rt_thread2_stack[1],      /* 线程栈起始地址 */
                   sizeof(rt_thread2_stack),
                   0); /* 线程栈大小 */
    /* 将线程插入就绪列表 */
    rt_list_insert_before(&(rt_thread_priority_table[1]), &(rt_thread2.tlist));

    /* 启动系统调度器 */
    rt_system_scheduler_start();
}

/* 软件延时 */
void delay(unsigned int count)
{
    count *= 50000;
    for(; count != 0; count--);
}

/* 线程 1 入口函数 */
void thread_1_entry(void *p_arg)
{
    rt_tick_t tick;

    for ( ;; ) 
    {
        printf("Thread 1 running...\n");

        tick = rt_tick_get();
        printf("the thread1 tick before is %d\n", tick);

        /* 阻塞线程 5s */
        rt_thread_delay(5);

        tick = rt_tick_get();
        printf("the thread1 tick after is %d\n", tick);
    }
}

/* 线程 2 入口函数 */
void thread_2_entry(void *p_arg)
{
    rt_tick_t tick;
    for ( ;; ) 
    {
        printf("Thread 2 running...\n");

        tick = rt_tick_get();
        printf("the thread2 tick before is %d\n", tick);

        /* 阻塞线程 5s */
        rt_thread_delay(5);

        tick = rt_tick_get();
        printf("the thread2 tick after is %d\n", tick);
    }
}

/* SysTick 中断处理函数 */
void SysTick_Handler(void)
{
    /* 时基更新 */
    rt_tick_increase();
}


