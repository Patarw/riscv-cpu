#include <rthw.h>
#include <rtthread.h>

/* 定义空闲线程栈大小 */
#define IDLE_THREAD_STACK_SIZE  128

/* 定义线程控制块 */
static struct rt_thread idle;

ALIGN(RT_ALIGN_SIZE)
/* 定义空闲线程栈 */
static rt_uint8_t rt_thread_stack[IDLE_THREAD_STACK_SIZE];

/* 空闲线程入口函数 */
static void rt_thread_idle_entry(void *parameter)
{
    while (1)
    {
        /* 这里暂时只打印信息 */
        printf("The idle thread is running...\n");
    }
}

/* 暂时使用 */
extern rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];

/**
 * @ingroup SystemInit
 *
 * This function will initialize idle thread, then start it.
 *
 * @note this function must be invoked when system init.
 */
void rt_thread_idle_init(void)
{
    /* 初始化线程 */
    rt_thread_init(&idle,
                   "tidle",
                   rt_thread_idle_entry,
                   RT_NULL,
                   &rt_thread_stack[0],
                   sizeof(rt_thread_stack),
                   0);
    
    /* 将线程插入就绪列表 */
    rt_list_insert_before(&(rt_thread_priority_table[RT_THREAD_PRIORITY_MAX-1]),
                          &(idle.tlist));
}

/**
 * @ingroup Thread
 *
 * This function will get the handler of the idle thread.
 *
 */
rt_thread_t rt_thread_idle_gethandler(void)
{
    return (rt_thread_t)(&idle);
}
