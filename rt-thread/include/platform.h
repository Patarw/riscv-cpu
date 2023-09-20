#ifndef __PLATFORM_H__
#define __PLATFORM_H__

#define MAX_CPU_NUM 1

#define CPU_FREQ_HZ (50000000)  //50MHz

/*
 * MemoryMap
 * 0x00000000 -- ROM
 * 0x10000000 -- RAM
 * 0x20000000 -- UART
 * 0x30000000 -- GPIO
 * 0x40000000 -- TIMER
 */
#define RAM   0x10000000L
#define UART  0x20000000L
#define GPIO  0x30000000L
#define TIMER 0x40000000L

#endif /* __PLATFORM_H__ */
