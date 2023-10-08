#ifndef FINSH_API_H__
#define FINSH_API_H__

#include "finsh_config.h"

typedef long (*syscall_func)(void);

/* system call table */
struct finsh_syscall
{
    const char*  name;   /* 系统调用的名称 */
#if defined(FINSH_USING_DESCRIPTION) && defined(FINSH_USING_SYMTAB)
    const char*  desc;   /* 系统调用的描述 */
#endif
    syscall_func func;   /* 系统调用的函数地址 */     
};
extern struct finsh_syscall *_syscall_table_begin, *_syscall_table_end;

#endif