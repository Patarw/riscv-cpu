#include <rthw.h>
#include <rtthread.h>

extern rt_list_t rt_thread_priority_table[RT_THREAD_PRIORITY_MAX];
extern struct rt_thread *rt_current_thread;

/**
 * This function will initialize a thread, normally it's used to initialize a
 * static thread object.
 *
 * @param thread the static thread object
 * @param name the name of thread, which shall be unique
 * @param entry the entry function of thread
 * @param parameter the parameter of thread enter function
 * @param stack_start the start address of thread stack
 * @param stack_size the size of thread stack
 *
 * @return the operation status, RT_EOK on OK, -RT_ERROR on error
 */
rt_err_t rt_thread_init(struct rt_thread *thread,
                        const char       *name,
                        void (*entry)(void *parameter),
                        void             *parameter,
                        void             *stack_start,
                        rt_uint32_t       stack_size,
                        rt_uint32_t       tick)
{
    /* 线程对象初始化，线程结构体开头部分的四个成员就是 rt_object */
    rt_object_init((rt_object_t)thread, RT_Object_Class_Thread, name);

    /* 初始化线程链表 */
    rt_list_init(&(thread->tlist));

    /* entry 是一个函数指针 */
    thread->entry = (void *)entry;
    thread->parameter = parameter;

    /* 初始化线程栈起始地址与大小 */
    thread->stack_addr = stack_start;
    thread->stack_size = stack_size;

    /* 初始化线程栈，并返回线程栈指针 */
    thread->sp = (void *)rt_hw_stack_init(thread->entry, thread->parameter,
                                          (rt_uint8_t *)((char *)thread->stack_addr + thread->stack_size - sizeof(rt_ubase_t)));
    
    /* tick init */
    thread->remaining_tick = tick;

    return RT_EOK;
}

/**
 * This function will return self thread object
 *
 * @return the self thread object
 */
rt_thread_t rt_thread_self(void)
{
    return rt_current_thread;
}

/**
 * This function will let current thread delay for some ticks.
 *
 * @param tick the delay ticks
 *
 * @return RT_EOK
 */
void rt_thread_delay(rt_tick_t tick)
{
    register rt_base_t temp;
    struct rt_thread *thread;

    /* 关中断 */
    temp = rt_hw_interrupt_disable();

    /* 获取当前线程的线程控制块 */
    thread = rt_current_thread;

    /* 设置延时时间 */
    thread->remaining_tick = tick;

    /* 恢复中断 */
    rt_hw_interrupt_enable(temp);

    /* 进行系统调度 */
    rt_schedule();
}
