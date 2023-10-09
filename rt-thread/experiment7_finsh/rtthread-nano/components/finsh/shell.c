#include <rthw.h>
#include <finsh_config.h>

#ifdef RT_USING_FINSH

#include "shell.h"


#ifndef RT_USING_HEAP
/* finsh 线程控制块 */
static struct rt_thread finsh_thread;

/* finsh 线程栈 */
ALIGN(RT_ALIGN_SIZE)
static char finsh_thread_stack[FINSH_THREAD_STACK_SIZE];

/* finsh_shell 结构体 */
struct finsh_shell _shell;
#endif

/* finsh symtab */
#ifdef FINSH_USING_SYMTAB
struct finsh_syscall *_syscall_table_begin = NULL;
struct finsh_syscall *_syscall_table_end   = NULL;
struct finsh_sysvar  *_sysvar_table_begin  = NULL;
struct finsh_sysvar  *_sysvar_table_end    = NULL;
#endif

struct finsh_shell *shell;

const char *finsh_get_prompt()
{
#define _MSH_PROMPT "msh >"

    static char finsh_prompt[RT_CONSOLEBUF_SIZE + 1] = {0};
    
    rt_strncpy(finsh_prompt, _MSH_PROMPT, RT_CONSOLEBUF_SIZE);

    return finsh_prompt;
}

static int finsh_getchar(void)
{
	int ch = -1;
	if ((ch = uart_getc()) == -1)
	    rt_thread_delay(1);

	return ch;
}

extern void delay(unsigned int);

/* finsh 线程入口函数 */
void finsh_thread_entry(void *parameter)
{
    int ch;

    /* normal is echo mode */
    shell->echo_mode = 1;
    
    printf(FINSH_PROMPT);

    while (1)
    {
        ch = uart_getc();
	delay(1);
        if (ch < 0)
        {
            continue;
        }
        
        /* received null or error */
        if (ch == '\0' || ch == 0xFF)
        {
            continue;
        }
        /* handle tab key */
        else if (ch == '\t')
        {
            printf("tab key!\r\n");
            continue;
        }
        /* handle backspace or del key */
        else if (ch == 0x7f || ch == 0x08)
        {
            if (shell->line_curpos == 0)
            	continue;

	    shell->line_position--;
	    shell->line_curpos--;

	    printf("\b \b");
	    shell->line[shell->line_position] = 0;

	    continue;
        }
        
        /* handle end of line, break */
        if (ch == '\r' || ch == '\n')
        {
            printf("\r\nreceived your command: %s\r\n", shell->line);
            printf(FINSH_PROMPT);
	    for (int i = 0;i < sizeof(shell->line); i++)
		shell->line[i] = 0;
            shell->line_curpos = shell->line_position = 0;
            continue;
        }
        
        /* it's a large line, discard it */
        if (shell->line_position >= FINSH_CMD_SIZE)
            shell->line_position = 0;

        /* normal character */
        shell->line[shell->line_curpos] = ch;
        if (shell->echo_mode)
            printf("%c", ch);
        
        ch = 0;
        shell->line_position++;
        shell->line_curpos++;
        if (shell->line_position >= FINSH_CMD_SIZE)
        {
            /* clear command line */
            shell->line_position = 0;
            shell->line_curpos = 0;
        }
    }
}

/* finsh 线程初始化函数 */
int finsh_system_init(void)
{
    rt_err_t result = RT_EOK;
    rt_thread_t tid;

    shell = &_shell;
    tid = &finsh_thread;
    result = rt_thread_init(&finsh_thread,
                            FINSH_THREAD_NAME,
                            finsh_thread_entry,
                            RT_NULL,
                            &finsh_thread_stack[0],
                            sizeof(finsh_thread_stack),
                            FINSH_THREAD_PRIORITY,
                            10);
    
    if (tid != NULL && result == RT_EOK)
        rt_thread_startup(tid);
    return 0;
}

#endif /* RT_USING_FINSH */
