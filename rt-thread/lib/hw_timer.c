#include "../include/platform.h"
#include "../include/hw_timer.h"

/* 硬件 timer 驱动代码 */

/*
 * The TIMER control registers are memory-mapped at address TIMER (defined in ../include/platform.h). 
 * This macro returns the address of one of the registers.
 */
#define TIMER_REG_ADDRESS(reg) ((volatile uint32_t *) (TIMER + reg))

/*
 * TIMER registers map
 * timer_count is a read-only reg
 */
#define TIMER_CTRL	 0
#define TIMER_COUNT	 4
#define TIMER_EVALUE 8

#define timer_read_reg(reg) (*(TIMER_REG_ADDRESS(reg)))
#define timer_write_reg(reg, data) (*(TIMER_REG_ADDRESS(reg)) = (data))

#define TIMER_EN	      1 << 0
#define TIMER_INT_EN      1 << 1
#define TIMER_INT_PENDING 1 << 2

#define TIMER_INTERVAL    CPU_FREQ_HZ / 10 // 定时器中断间隔

extern void SysTick_Handler(void) __attribute__((weak));

/* 初始化硬件定时器 */
void hw_timer_init()
{
    /* 使能定时器中断 */
	timer_write_reg(TIMER_CTRL, (timer_read_reg(TIMER_CTRL) | (TIMER_INT_EN)));
	hw_timer_set(TIMER_INTERVAL);
}

/* 设置定时器，传入参数的单位为 cpu 的时钟周期 */
void hw_timer_set(uint32_t interval)
{
    timer_write_reg(TIMER_EVALUE, interval);
    timer_write_reg(TIMER_CTRL, (timer_read_reg(TIMER_CTRL) | (TIMER_EN)));
}

/* 定时器中断处理函数 */
void hw_timer_irq_handler()
{
	timer_write_reg(TIMER_CTRL, (timer_read_reg(TIMER_CTRL) & ~(TIMER_INT_PENDING)));
    
    /* 调用 SysTick_Handler 处理函数 */
	SysTick_Handler();

	hw_timer_set(TIMER_INTERVAL);
}
