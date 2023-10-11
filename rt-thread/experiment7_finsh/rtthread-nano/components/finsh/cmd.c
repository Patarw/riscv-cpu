#include <rthw.h>
#include <rtthread.h>
#include <finsh_config.h>

#ifdef RT_USING_FINSH

#include "finsh.h"

long hello(void)
{
    printf("Hello RT-Thread!\r\n");

    return 0;
}

MSH_CMD_EXPORT(hello, say hello world);

#endif