#ifndef __TIMER_H__
#define __TIMER_H__
#include "types.h"

/* timer */
extern void hw_timer_init();
extern void hw_timer_set(uint32_t interval);
extern void hw_timer_irq_handler();

#endif