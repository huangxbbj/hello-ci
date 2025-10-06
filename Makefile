# Simple Makefile for C/C++ CI Example

CC      := gcc
CFLAGS  := -Wall -Wextra -O2
TARGET  := hello

SRC     := $(wildcard *.c)
OBJ     := $(SRC:.c=.o)

# Default rule
all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Run tests (placeholder)
check: $(TARGET)
	@echo "Running tests..."
	@./$(TARGET)

# Clean up
clean:
	rm -f $(OBJ) $(TARGET)

# Dist target for demonstration (mimics autotools)
distcheck: all check
	@echo "Distribution check successful."

.PHONY: all check clean distcheck
