#ifndef __RT_HW_H__
#define __RT_HW_H__

#include <rtthread.h>

rt_uint8_t *rt_hw_stack_init(void       *tentry,
                             void       *parameter,
                             rt_uint8_t *stack_addr);

/*
 * Context interfaces
 */
void rt_hw_context_switch(rt_ubase_t from, rt_ubase_t to);
void rt_hw_context_switch_to(rt_ubase_t to);

#endif
