CC      := gcc
CFLAGS  := -Wall -Wextra -O2
TARGET  := hello
TESTBIN := test_hello

SRC     := hello.c
TESTSRC := test_hello.c unity/unity.c

all: $(TARGET)

# Build production executable
$(TARGET): hello-ci.c hello.c
	$(CC) $(CFLAGS) -o $@ hello-ci.c hello.c

# Build test executable
$(TESTBIN): $(TESTSRC) $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

check: $(TESTBIN)
	@echo "Running unit tests..."
	@./$(TESTBIN)

# Run system/functional test
functional: $(TARGET)
	@echo "Running functional test..."
	@expected_output="Hello, CI/CD world!\n2 + 3 = 5\n5 - 3 = 2"
	@output=`./$(TARGET)`; \
	if [ "$$output" = "$$(printf "$$expected_output")" ]; then \
		echo "Functional test PASSED ✅"; \
	else \
		echo "Functional test FAILED ❌"; \
		echo "Expected:"; \
		printf "$$expected_output\n"; \
		echo "Got:"; \
		echo "$$output"; \
		exit 1; \
	fi

clean:
	rm -f $(TARGET) $(TESTBIN) *.o

distcheck: all check
	@echo "Distribution check successful."

.PHONY: all check clean distcheck
