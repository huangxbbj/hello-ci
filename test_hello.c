#include "unity/unity.h"
#include "stdio.h"
#include "hello.h"   // contains prototypes for add() and sub()


void setUp(void) {}
void tearDown(void) {}

void test_add(void) {
    TEST_ASSERT_EQUAL_INT(5, add(2, 3));
    TEST_ASSERT_EQUAL_INT(0, add(-1, 1));
}

void test_sub(void) {
    TEST_ASSERT_EQUAL_INT(2, sub(5, 3));
    TEST_ASSERT_EQUAL_INT(-2, sub(-1, 1));
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_add);
    RUN_TEST(test_sub);
    return UNITY_END();
}
