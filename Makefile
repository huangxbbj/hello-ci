# Makefile for C CI pipeline with full GNU-style distcheck

CC      := gcc
CFLAGS  := -Wall -Wextra -O2
TARGET  := hello
TESTBIN := test_hello
DISTDIR := dist
VERSION := 1.0.0
PKGNAME := hello-$(VERSION)
DISTFILE := $(DISTDIR)/$(PKGNAME).tar.gz

SRC     := main.c
TESTSRC := test_hello.c unity/unity.c
HEADERS := hello.h unity/unity.h
EXTRA   := Makefile hello-ci.c README.md

all: $(TARGET)

$(TARGET): main.c $(SRC)
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

# 1️⃣ Create source distribution
dist:
	@echo "Creating source distribution..."
	@mkdir -p $(DISTDIR)/$(PKGNAME)
	@cp -r $(SRC) $(TESTSRC) $(HEADERS) $(EXTRA) unity $(DISTDIR)/$(PKGNAME) 2>/dev/null || true
	@tar -czf $(DISTFILE) -C $(DISTDIR) $(PKGNAME)
	@echo "Created: $(DISTFILE)"

# 2️⃣ Full GNU-style distribution check
distcheck: dist
	@echo "Running distribution check..."
	@TMPDIR=$$(mktemp -d); \
	echo "Unpacking tarball in $$TMPDIR"; \
	tar -xzf $(DISTFILE) -C $$TMPDIR; \
	cd $$TMPDIR/$(PKGNAME) && \
		echo "Building project..." && \
		$(MAKE) all && \
		echo "Running unit tests..." && \
		$(MAKE) check && \
		echo "Running functional tests..." && \
		$(MAKE) functional && \
		echo "✅ All tests passed in distribution build."; \
	rm -rf $$TMPDIR
	@echo "Distribution check successful ✅"

clean:
	rm -f $(TARGET) $(TESTBIN) *.o
	rm -rf $(DISTDIR)

.PHONY: all check functional dist distcheck clean
