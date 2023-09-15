#ifndef __UART_H__
#define __UART_H__
#include "types.h"

/* uart */
extern void uart_init();
extern void uart_putc(char ch);
extern void uart_puts(char *s);
extern char uart_getc();
extern void uart_gets(char *s, uint8_t len);

#endif
