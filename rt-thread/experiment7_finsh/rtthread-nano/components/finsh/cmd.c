#include <rthw.h>
#include <rtthread.h>
#include <finsh_config.h>

#ifdef RT_USING_FINSH

#include "finsh.h"

#define LIST_FIND_OBJ_NR 8

long hello(void)
{
    printf("Hello RT-Thread!\r\n");

    return 0;
}
MSH_CMD_EXPORT(hello, say hello world);

/* 列出所有命令 */
long list(void)
{
    printf("--Function List:\r\n");
    {
        struct finsh_syscall *index;
        for (index = _syscall_table_begin; index < _syscall_table_end; index++)
        {
            printf("%s: %s\r\n", &index->name[6], index->desc);
        }
    }

    return 0;
}
MSH_CMD_EXPORT(list, list all command);


/* 列出所有线程信息 */
long list_thread(void)
{
    /* 获取线程对象容器 */
    struct rt_object_information *information;
    information = rt_object_get_information(RT_Object_Class_Thread);
    struct rt_object *object = RT_NULL;
    struct rt_list_node *index = RT_NULL;
    struct rt_list_node *head = &(information->object_list);

    printf("name       pri   status       sp       stack size   used   left tick   error\r\n"); 
    printf("--------   ---   ------   ----------   ----------   ----   ---------   -----\r\n");

    for (index = head->next; index != head; index = index->next)
    {
        rt_uint8_t stat;
        rt_uint8_t *ptr;

        struct rt_thread *thread;
        object = rt_list_entry(index, struct rt_object, list);
        thread = (struct rt_thread*)object;


        printf("%s     %d   ", thread->name, thread->current_priority);

        stat = (thread->stat & RT_THREAD_STAT_MASK);
        if (stat == RT_THREAD_READY)        printf(" ready  ");
        else if (stat == RT_THREAD_SUSPEND) printf(" suspend");
        else if (stat == RT_THREAD_INIT)    printf(" init   ");
        else if (stat == RT_THREAD_CLOSE)   printf(" close  ");
        else if (stat == RT_THREAD_RUNNING) printf(" running");
        
        ptr = (rt_uint8_t *)thread->stack_addr;
        while (*ptr == '#')ptr ++;

        printf("  0x%x      %dB      %dB       %d        %d\r\n",
                thread->sp,
                thread->stack_size,
                (thread->stack_size - ((rt_ubase_t) ptr - (rt_ubase_t) thread->stack_addr)),
                thread->remaining_tick,
                thread->error);
    }
    
    return 0;
}
MSH_CMD_EXPORT(list_thread, list all thread);
#endif