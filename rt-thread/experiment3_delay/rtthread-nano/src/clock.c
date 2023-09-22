#include <rthw.h>
#include <rtthread.h>

/* 系统时基计数器 */
static rt_tick_t rt_tick = 0;
extern rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];

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
    rt_ubase_t i;

    /* increase the global tick */
    ++ rt_tick;

    /* 扫描就绪列表中所有线程的 remaining_tick，如果不为 0，则减 1 */
    for (i = 0; i < RT_THREAD_PRIORITY_MAX; i++)
    {
        thread = rt_list_entry(rt_thread_priority_table[i].next,
                               struct rt_thread,
                               tlist);
        if (thread->remaining_tick > 0)
        {
            -- thread->remaining_tick;
        }
    }

    /* 系统调度 */
    rt_schedule();
}
