#include <rthw.h>
#include <rtthread.h>

rt_err_t rt_thread_init(struct rt_thread *thread,
                        void (*entry)(void *parameter),
                        void             *parameter,
                        void             *stack_start,
                        rt_uint32_t       stack_size)
{
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
                                          (rt_uint8_t *)((char *)thread->stack_addr + thread->stack_size - 4));
    
    return RT_EOK;
}
