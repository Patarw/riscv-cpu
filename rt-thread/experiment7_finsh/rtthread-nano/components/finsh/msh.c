#include <rtthread.h>
#include <finsh_config.h>

#ifdef FINSH_USING_MSH

#include "msh.h"
#include <finsh.h>
#include <shell.h>

#ifndef FINSH_ARG_MAX
#define FINSH_ARG_MAX   8
#endif

typedef int (*cmd_function_t)(int argc, char **argv);

#ifdef FINSH_USING_MSH_ONLY
rt_bool_t msh_is_used(void)
{
    return RT_TRUE;
}
#endif

static int msh_split(char *cmd, rt_size_t length, char *argv[FINSH_ARG_MAX])
{
    char *ptr;
    rt_size_t position;
    rt_size_t argc;
    rt_size_t i;

    ptr = cmd;
    position = 0;
    argc = 0;

    while (position < length)
    {
        /* strip bank and tab */
        while ((*ptr == ' ' || *ptr == '\t') && position < length)
        {
            *ptr = '\0';
            ptr++;
            position++;
        }
        
        if(argc >= FINSH_ARG_MAX)
        {
            printf("Too many args ! We only Use:\n");
            for(i = 0; i < argc; i++)
            {
                printf("%s ", argv[i]);
            }
            printf("\n");
            break;
        }

        if (position >= length) break;
        
        /* handle string */
        if (*ptr == '"')
        {
            ptr++; position++;
            argv[argc] = ptr; argc++;

            /* skip this string */
            while (*ptr != '"' && position < length)
            {
                if (*ptr == '\\')
                {
                    if (*(ptr + 1) == '"')
                    {
                        ptr++; position++;
                    }
                }
                ptr++; position++;
            }
            if (position >= length) break;

            /* skip '"' */
            *ptr = '\0'; ptr++; position++;
        }
        else
        {
            argv[argc] = ptr;
            argc++;
            while ((*ptr != ' ' && *ptr != '\t') && position < length)
            {
                ptr++; position++;
            }
            if (position >= length) break;
        }
    }
    
    return argc;
}

extern long hello(void);

static cmd_function_t msh_get_cmd(char *cmd, int size)
{
    struct finsh_syscall *index;
    cmd_function_t cmd_func = RT_NULL;

    cmd_func = (cmd_function_t)hello;
    return cmd_func;

    for (index = _syscall_table_begin; index < _syscall_table_end; index++)
    {
        if (rt_strncmp(index->name, "__cmd_", 6) != 0) continue;
        
        if (rt_strncmp(&index->name[6], cmd, size) == 0 && index->name[6 + size] == '\0')
        {
            cmd_func = (cmd_function_t)index->func;
            break;
        }
    }
    
    return cmd_func;
}

static int _msh_exec_cmd(char *cmd, rt_size_t length, int *retp)
{
    int argc;
    rt_size_t cmd0_size = 0;
    cmd_function_t cmd_func;
    char *argv[FINSH_ARG_MAX];

    /* find the size of first command */
    while ((cmd[cmd0_size] != ' ' && cmd[cmd0_size] != '\t') && cmd0_size < length)
        cmd0_size++;
    if (cmd0_size == 0)
        return -RT_ERROR;
    
    /* 获取命令对应的函数指针 */
    cmd_func = msh_get_cmd(cmd, cmd0_size);
    if (cmd_func == RT_NULL)
        return -RT_ERROR;
    
    /* 分割 cmd 的命令和参数 */
    rt_memset(argv, 0x00, sizeof(argv));
    //argc = msh_split(cmd, length, argv);
    //if (argc == 0)
    //    return -RT_ERROR;
    
    /* 执行命令 */
    *retp = cmd_func(argc, argv);

    return 0;
}

int msh_exec(char *cmd, rt_size_t length)
{
    int cmd_ret;

    /* strim the beginning of command */
    while ((length > 0) && (*cmd == ' ' || *cmd == '\t'))
    {
        cmd++;
        length--;
    }

    if (length == 0)
    {
        return 0;
    }
    
    /* Exec sequence:
     * 1. built-in command
     * 2. module(if enabled)
     */
    if (_msh_exec_cmd(cmd, length, &cmd_ret) == 0)
    {
        return cmd_ret;
    }

    /* truncate the cmd at the first space. */
    {
        char *tcmd;
        tcmd = cmd;
        while (*tcmd != ' ' && *tcmd != '\0')
        {
            tcmd++;
        }
        *tcmd = '\0';
    }

    printf("%s: command not found.\r\n", cmd);
    return -1;
}


#endif /* FINSH_USING_MSH */