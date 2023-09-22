#ifndef __RT_THREAD_H__
#define __RT_THREAD_H__

#include <rtdef.h>
#include <rtservice.h>
#include <rtconfig.h>

#include <printf.h>

/*
 * kernel object interface
 */
struct rt_object_information *
rt_object_get_information(enum rt_object_class_type type);
void rt_object_init(struct rt_object         *object,
                    enum rt_object_class_type type,
                    const char               *name);

/*
 * clock & timer interface
 */
rt_tick_t rt_tick_get(void);
void rt_tick_increase(void);

/*
 * thread interface
 */
rt_err_t rt_thread_init(struct rt_thread *thread,
                        const char       *name,
                        void (*entry)(void *parameter),
                        void             *parameter,
                        void             *stack_start,
                        rt_uint32_t       stack_size,
                        rt_uint32_t       tick);
rt_thread_t rt_thread_self(void);
void rt_thread_delay(rt_tick_t tick);

/*
 * idle thread interface
 */
void rt_thread_idle_init(void);
rt_thread_t rt_thread_idle_gethandler(void);

/*
 * schedule service
 */
void rt_system_scheduler_init(void);
void rt_system_scheduler_start(void);
void rt_schedule(void);

/*
 * interrupt service
 */

/*
 * rt_interrupt_enter and rt_interrupt_leave only can be called by BSP
 */
void rt_interrupt_enter(void);
void rt_interrupt_leave(void);

/*
 * general kernel service
 */
char *rt_strncpy(char *dest, const char *src, rt_ubase_t n);

#endif
