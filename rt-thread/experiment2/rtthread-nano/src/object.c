#include <rtthread.h>
#include <rthw.h>

/*
 * define object_info for the number of rt_object_container items.
 * 里面的成员随 config 文件中的定义而变化，作为容器数组的下标。
 * 注：如果枚举类型的成员值没有具体指定，那么最后一个值是在前一个成员值的基础上加 1
 */
enum rt_object_info_type
{
    RT_Object_Info_Thread = 0,                         /* 线程 */
#ifdef RT_USING_SEMAPHORE
    RT_Object_Info_Semaphore,                          /* 信号量 */
#endif
#ifdef RT_USING_MUTEX
    RT_Object_Info_Mutex,                              /* 互斥量 */
#endif
#ifdef RT_USING_EVENT
    RT_Object_Info_Event,                              /* 事件 */
#endif
#ifdef RT_USING_MAILBOX
    RT_Object_Info_MailBox,                            /* 邮箱 */
#endif
#ifdef RT_USING_MESSAGEQUEUE
    RT_Object_Info_MessageQueue,                       /* 消息队列 */
#endif
#ifdef RT_USING_MEMHEAP
    RT_Object_Info_MemHeap,                            /* 内存堆 */
#endif
#ifdef RT_USING_MEMPOOL
    RT_Object_Info_MemPool,                            /* 内存池 */
#endif
#ifdef RT_USING_DEVICE
    RT_Object_Info_Device,                             /* 设备 */
#endif
    RT_Object_Info_Timer,                              /* 定时器 */
    RT_Object_Info_Unknown,                            /* 未知对象 */
};
