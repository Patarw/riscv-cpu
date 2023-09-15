#include <rtthread.h>
#include <rthw.h>

/* 线程就绪列表 */
rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];

/* 当前线程控制块指针 */
struct rt_thread *rt_current_thread = RT_NULL;

/**
 * @ingroup SystemInit
 * This function will initialize the system scheduler
 */
void rt_system_scheduler_init(void)
{
    register rt_base_t offset;

    /* 线程就绪列表初始化 */
    for (offset = 0; offset < RT_THREAD_PRIORITY_MAX; offset ++)
    {
        rt_list_init(&rt_thread_priority_table[offset]);
    }

    /* 初始化当前线程控制块指针 */
    rt_current_thread = RT_NULL;
}

/**
 * @ingroup SystemInit
 * This function will startup scheduler. It will select one thread
 * with the highest priority level, then switch to it.
 */
void rt_system_scheduler_start(void)
{
    register struct rt_thread *to_thread;

    /* 获取第一个运行的线程指针 */
    to_thread = rt_list_entry(rt_thread_priority_table[0].next,
                              struct rt_thread,
                              tlist);
    
    rt_current_thread = to_thread;

    /* 切换到新线程 */
    rt_hw_context_switch_to((rt_uint32_t)&to_thread->sp);

    /* never come back */
}

/**
 * This function will perform one schedule. It will select one thread
 * with the highest priority level, then switch to it.
 */
void rt_schedule(void)
{
    struct rt_thread *to_thread;
    struct rt_thread *from_thread;

    /* 只有两个线程轮流切换 */
    if (rt_current_thread == rt_list_entry(rt_thread_priority_table[0].next,
                                           struct rt_thread,
                                           tlist))
    {
        from_thread = rt_current_thread;
        to_thread =  rt_list_entry(rt_thread_priority_table[1].next,
                                   struct rt_thread,
                                   tlist);
        rt_current_thread = to_thread;
    }
    else 
    {
        from_thread = rt_current_thread;
        to_thread =  rt_list_entry(rt_thread_priority_table[0].next,
                                   struct rt_thread,
                                   tlist);
        rt_current_thread = to_thread;
    }
    /* 产生上下文切换 */
    rt_hw_context_switch((rt_uint32_t)&from_thread->sp, 
                         (rt_uint32_t)&to_thread->sp);
}