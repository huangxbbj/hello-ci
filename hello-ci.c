// hello-ci.c
#include <stdio.h>
#include "hello.h"

int main(void) {
    printf("Hello, CI/CD world!\n");
    printf("2 + 3 = %d\n", add(2, 3));
    printf("5 - 3 = %d\n", sub(5, 3));
    return 0;
}
