#include "unity/unity.h"
#include "stdio.h"

// Declaration of the function under test
int add(int a, int b);

void setUp(void) {}
void tearDown(void) {}

void test_addition_should_work(void) {
    TEST_ASSERT_EQUAL_INT(5, add(2, 3));
    TEST_ASSERT_EQUAL_INT(0, add(-2, 2));
    TEST_ASSERT_EQUAL_INT(-4, add(-2, -2));
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_addition_should_work);
    return UNITY_END();
}
