#include <rtthread.h>
#include <rthw.h>

/* 线程就绪列表 */
rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];

/* 中断嵌套层数 */
extern volatile rt_uint8_t rt_interrupt_nest;

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
 * 因为本章节没有涉及到线程优先级，所以默认选择第一个线程
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
 * 因为本章节没有涉及到线程优先级，所以默认调度器为两个线程轮流执行
 */
void rt_schedule(void)
{
    struct rt_thread *to_thread;
    struct rt_thread *from_thread;

    struct rt_thread *idle =  rt_thread_idle_gethandler();
    struct rt_thread *thread1 = rt_list_entry(rt_thread_priority_table[0].next,
                                              struct rt_thread,
                                              tlist);
    struct rt_thread *thread2 = rt_list_entry(rt_thread_priority_table[1].next,
                                              struct rt_thread,
                                              tlist);
    /* 如果当前线程为空闲线程，则就去尝试执行线程1或2 */
    if (rt_current_thread == idle)
    {
        if (thread1->remaining_tick == 0)
        {
            from_thread = rt_current_thread;
            to_thread = thread1;
            rt_current_thread = to_thread;
        }
        else if (thread2->remaining_tick == 0)
        {
            from_thread = rt_current_thread;
            to_thread = thread2;
            rt_current_thread = to_thread;
        }
        else
        {
            return;  /* 如果两个线程均在延时则返回，继续执行空闲线程 */
        }
    }
    /* 如果当前线程不是空闲线程 */
    else
    {
        /* 假如当前线程为线程1 */
        if (rt_current_thread == thread1)
        {
            /* 如果线程2不需要延时，则切换到线程2 */
            if (thread2->remaining_tick == 0)
            {
                from_thread = rt_current_thread;
                to_thread = thread2;
                rt_current_thread = to_thread;
            }
            /* 假如当前线程也需要延时，则切换到空闲线程 */
            else if (rt_current_thread->remaining_tick != 0)
            {
                from_thread = rt_current_thread;
                to_thread = idle;
                rt_current_thread = to_thread;
            }
            else
            {
                return;  /* 返回，继续执行当前线程 */
            }
        }
        /* 假如当前线程为线程2 */
        else if (rt_current_thread == thread2)
        {
            /* 如果线程1不需要延时，则切换到线程1 */
            if (thread1->remaining_tick == 0)
            {
                from_thread = rt_current_thread;
                to_thread = thread1;
                rt_current_thread = to_thread;
            }
            /* 假如当前线程也需要延时，则切换到空闲线程 */
            else if (rt_current_thread->remaining_tick != 0)
            {
                from_thread = rt_current_thread;
                to_thread = idle;
                rt_current_thread = to_thread;
            }
            else
            {
                return;  /* 返回，继续执行当前线程 */
            }
        }
    }

    /* 上下文切换 */
    if (rt_interrupt_nest == 0)  /* 若 rt_interrupt_nest = 0 则表示当前未处在中断状态 */
    {
        rt_hw_context_switch((rt_uint32_t)&from_thread->sp, 
                             (rt_uint32_t)&to_thread->sp);
    }
    else
    {
        rt_hw_context_switch_interrupt((rt_ubase_t)&from_thread->sp,
                                       (rt_ubase_t)&to_thread->sp);
    }
}
