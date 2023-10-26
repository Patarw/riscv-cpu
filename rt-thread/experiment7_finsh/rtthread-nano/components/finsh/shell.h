#ifndef __SHELL_H__
#define __SHELL_H__

#include <rtthread.h>
#include "finsh.h"

#ifndef FINSH_CMD_SIZE
#define FINSH_CMD_SIZE      80
#endif

#define FINSH_PROMPT        finsh_get_prompt()
const char* finsh_get_prompt(void);

#ifndef FINSH_THREAD_NAME
#define FINSH_THREAD_NAME   "tshell "
#endif

enum input_stat
{
    WAIT_NORMAL,
    WAIT_SPEC_KEY,
    WAIT_FUNC_KEY,
};

struct finsh_shell
{
    enum input_stat stat;

    rt_uint8_t echo_mode:1;
    rt_uint8_t prompt_mode:1;

    char line[FINSH_CMD_SIZE];
    rt_uint16_t line_position;
    rt_uint16_t line_curpos;
};

int finsh_system_init(void);

#endif
