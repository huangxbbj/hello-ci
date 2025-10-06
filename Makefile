# Simple Makefile for C CI pipeline with unit + functional tests + dist packaging

CC      := gcc
CFLAGS  := -Wall -Wextra -O2
TARGET  := hello
TESTBIN := test_hello
DISTDIR := dist
VERSION := 1.0.0
DISTFILE := $(DISTDIR)/hello-$(VERSION).tar.gz

SRC     := hello.c
TESTSRC := test_hello.c unity/unity.c
HEADERS := hello.h unity/unity.h
EXTRA   := Makefile hello-ci.c README.md

all: $(TARGET)

$(TARGET): hello-ci.c $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

$(TESTBIN): $(TESTSRC) $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

check: $(TESTBIN)
	@echo "Running unit tests..."
	@./$(TESTBIN)

functional: $(TARGET)
	@echo "Running functional test..."
	@output=$$(./$(TARGET)); \
	expected_output="Hello, CI/CD world!\n2 + 3 = 5\n5 - 3 = 2"; \
	if [ "$$output" = "$$(printf "$$expected_output")" ]; then \
		echo "Functional test PASSED ✅"; \
	else \
		echo "Functional test FAILED ❌"; \
		echo "Expected:"; printf "$$expected_output\n"; \
		echo "Got:"; echo "$$output"; \
		exit 1; \
	fi

# 🔹 Create a distribution tarball
dist:
	@echo "Creating source distribution..."
	@mkdir -p $(DISTDIR)/hello-$(VERSION)
	@cp -r $(SRC) $(TESTSRC) $(HEADERS) $(EXTRA) unity $(DISTDIR)/hello-$(VERSION) 2>/dev/null || true
	@tar -czf $(DISTFILE) -C $(DISTDIR) hello-$(VERSION)
	@echo "Distribution package created: $(DISTFILE)"
	@ls -lh $(DISTFILE)

# 🔹 Full distribution check: build + test
distcheck: all check functional
	@echo "All tests passed ✅"
	@$(MAKE) dist

clean:
	rm -f $(TARGET) $(TESTBIN) *.o
	rm -rf $(DISTDIR)

.PHONY: all check functional dist distcheck clean
