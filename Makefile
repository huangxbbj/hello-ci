# Makefile for C CI pipeline with Unity tests

CC      := gcc
CFLAGS  := -Wall -Wextra -O2
TARGET  := hello
TESTBIN := test_hello

SRC     := hello.c          # library code only, no main()
TESTSRC := test_hello.c unity/unity.c

all: $(TARGET)

# Build production executable
$(TARGET): hello-ci.c
	$(CC) $(CFLAGS) -o $@ $^

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
