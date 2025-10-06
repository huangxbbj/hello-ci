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

clean:
	rm -f $(TARGET) $(TESTBIN) *.o

distcheck: all check
	@echo "Distribution check successful."

.PHONY: all check clean distcheck
