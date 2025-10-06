#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main(void) {
    printf("Hello, CI/CD world! 2 + 3 = %d\n", add(2, 3));
    return 0;
}
