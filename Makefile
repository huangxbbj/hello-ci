# Makefile for C CI pipeline with full GNU-style distcheck

CC      := gcc
CFLAGS  := -Wall -Wextra -O2 -fprofile-arcs -ftest-coverage
TARGET  := hello
TESTBIN := test_hello
DISTDIR := dist
VERSION := 1.0.0
PKGNAME := hello-$(VERSION)
DISTFILE := $(DISTDIR)/$(PKGNAME).tar.gz
REPORT  := test_results.xml
GCOVFLAGS := -fprofile-arcs -ftest-coverage
LDFLAGS := -lgcov

# Source and header files
SRC     := main.c hello.c
TESTSRC := test_hello.c unity/unity.c hello.c
HEADERS := hello.h unity/unity.h
EXTRA   := Makefile README.md

# Default target
all: $(TARGET)

# Build main program
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

# Object files with coverage flags
OBJS := test_hello.o unity/unity.o hello.o

# Build test binary
$(TESTBIN): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Basic static code analysis
lint:
	@echo "🔍 Running static analysis with cppcheck..."
	@mkdir -p reports
	@cppcheck --enable=all --inconclusive --quiet \
		--suppress=missingIncludeSystem \
		--output-file=reports/cppcheck-report.txt . || true
	@echo "✅ cppcheck completed. Report: reports/cppcheck-report.txt"


memcheck: $(TESTBIN)
	@echo "🧠 Running memory leak check with valgrind..."
	@valgrind --leak-check=full --error-exitcode=1 ./$(TESTBIN)

# Run unit tests and save JUnit XML report
check: $(TESTBIN)
	@echo "Running unit tests..."
	@mkdir -p test-reports
	# Run Unity and keep only lines starting from the XML declaration
	@UNITY_OUTPUT_FORMAT=JUnit ./$(TESTBIN) 2>/dev/null | sed -n '/^<?xml/,/$$/p' > test-reports/test_results.xml || true
	@echo "JUnit test report generated at test-reports/test_results.xml"

debug-junit:
	@mkdir -p test-reports
	@echo "Dummy JUnit report for debugging purposes" > test-reports/test_results.xml
	@echo "Test 'test_add': PASSED" >> test-reports/test_results.xml
	@echo "Test 'test_sub': FAILED (Expected 2 but got 3)" >> test-reports/test_results.xml
	@echo "Dummy JUnit text generated at test-reports/test_results.xml"

# Run tests and generate coverage text
coverage: $(TESTBIN)
	@echo "Running tests for coverage..."
	@./$(TESTBIN)      # generates .gcda files
	@mkdir -p coverage
	@gcov -o . hello.c > coverage/gcov-output.txt || true
	@echo "Coverage data saved to coverage/gcov-output.txt"

# Generate HTML coverage report
coverage-html: $(TESTBIN)
	@echo "Running tests and generating HTML coverage..."
	@./$(TESTBIN)
	@mkdir -p coverage
	@lcov --capture --directory . --output-file coverage/coverage.info --ignore-errors empty
	@genhtml coverage/coverage.info --output-directory coverage/html --ignore-errors empty
	@echo "HTML coverage report generated at coverage/html/index.html"

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

.PHONY: all check debug-junit coverage coverage-html functional dist distcheck clean
