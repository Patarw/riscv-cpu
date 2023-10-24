/* 头文件声明 */
#include <rtthread.h>
#include <rtconfig.h>
#include <rthw.h>
#include "../../include/printf.h"
#include "../../include/uart.h"

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
    uart_init(); /*  */

    /* 调度器初始化 */
    rt_system_scheduler_init();

    /* 初始化线程 */
    rt_thread_init(&rt_thread1,               /* 线程控制块 */
                   thread_1_entry,            /* 线程入口地址 */
                   RT_NULL,                   /* 线程形参 */
                   &rt_thread1_stack[0],      /* 线程栈起始地址 */
                   sizeof(rt_thread1_stack)); /* 线程栈大小 */
    /* 将线程插入就绪列表 */
    rt_list_insert_before(&(rt_thread_priority_table[0]), &(rt_thread1.tlist));

    /* 初始化线程 */
    rt_thread_init(&rt_thread2,               /* 线程控制块 */
                   thread_2_entry,            /* 线程入口地址 */
                   RT_NULL,                   /* 线程形参 */
                   &rt_thread2_stack[0],      /* 线程栈起始地址 */
                   sizeof(rt_thread2_stack)); /* 线程栈大小 */
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
    for ( ;; ) 
    {
        printf("Thread 1 running...\n");
        delay(100);
        rt_schedule();
    }
}

/* 线程 2 入口函数 */
void thread_2_entry(void *p_arg)
{
    for ( ;; ) 
    {
        printf("Thread 2 running...\n");
        delay(100);
        rt_schedule();
    }
}



