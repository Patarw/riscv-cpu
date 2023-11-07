/* 头文件声明 */
#include "../include/printf.h"
#include "../include/uart.h"

/* main 函数 */
int main(void)
{
    int a = 1;
    int b = 2;
    int c = a + b;
    printf("The result of c: %d\n", c);

    /* stop here */
    while(1){};
}
