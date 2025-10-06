# Makefile for C CI pipeline with Unity tests

CC      := gcc
CFLAGS  := -Wall -Wextra -O2
TARGET  := hello
TESTBIN := test_hello

SRC     := main.c
TESTSRC := test_hello.c unity/unity.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

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
