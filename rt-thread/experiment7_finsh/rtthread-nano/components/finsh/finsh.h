#ifndef __FINSH_H__
#define __FINSH_H__

#include <rtthread.h>
#include "finsh_api.h"

/* system variable table */
struct finsh_sysvar
{
    const char*     name;   /* 变量的名称 */
#if defined(FINSH_USING_DESCRIPTION) && defined(FINSH_USING_SYMTAB)
    const char*     desc;   /* 系统变量的描述 */
#endif
    rt_uint8_t      type;   /* 变量的类型 */
    void*           var;    /* 变量的地址 */
};

#endif