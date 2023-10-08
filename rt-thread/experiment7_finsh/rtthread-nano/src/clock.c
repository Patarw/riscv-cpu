#include <rthw.h>
#include <rtthread.h>

/* 系统时基计数器 */
static rt_tick_t rt_tick = 0;
extern rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];
extern rt_uint32_t rt_thread_ready_priority_group;

/**
 * This function will return current tick from operating system startup
 *
 * @return current tick
 */
rt_tick_t rt_tick_get(void)
{
    /* return the global tick */
    return rt_tick;
}

/**
 * This function will notify kernel there is one tick passed. Normally,
 * this function is invoked by clock ISR.
 */
void rt_tick_increase(void)
{
    struct rt_thread *thread;

    /* 系统时基计数器加 1 */
    ++ rt_tick;

    thread = rt_thread_self();

    /* 时间片递减 */
    -- thread->remaining_tick;

    /* 检查当前线程的时间片是否用尽 */
    if (thread->remaining_tick == 0)
    {
        /* 重置时间片 */
        thread->remaining_tick = thread->init_tick;

        /* 让出处理器 */
        rt_thread_yield();
    }
    

    /* 扫描定时器列表 */
    rt_timer_check();
}
