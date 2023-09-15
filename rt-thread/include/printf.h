#ifndef __PRINTF_H__
#define __PRINTF_H__

#include <stddef.h>
#include <stdarg.h>

/* printf */
int printf(const char* s, ...);
void panic(char *s);

#endif
