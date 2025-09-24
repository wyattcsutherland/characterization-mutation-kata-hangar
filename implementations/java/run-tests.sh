#!/bin/bash

# Java Gilded Rose Environment Verification Script
# This script verifies the Java environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

# Check if we're in the correct directory
if [ ! -f "build.gradle" ]; then
    echo "❌ Error: build.gradle not found. Please run this script from the Java implementation directory."
    exit 1
fi

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java is not installed or not in PATH"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo "✅ Java found: $JAVA_VERSION"

# Check if gradlew is executable
if [ ! -x "./gradlew" ]; then
    echo "🔧 Making gradlew executable..."
    chmod +x ./gradlew
fi

# Verify project structure
if [ ! -d "src/main/java/com/gildedrose" ]; then
    echo "❌ Error: Main source directory not found"
    exit 1
fi

if [ ! -d "src/test/java/com/gildedrose" ]; then
    echo "❌ Error: Test source directory not found"
    exit 1
fi

# Build the project (without running tests)
if ! ./gradlew assemble -q; then
    echo "❌ Error: Build failed"
    exit 1
fi

# Run only the main Gilded Rose test (excluding secret tests)
echo "🧪 Running Gilded Rose tests..."

# Temporarily disable exit on error for test execution
set +e

# Record start time
START_TIME=$(date +%s.%3N)

# Capture test output and exit code with detailed info and coverage
TEST_OUTPUT=$(./gradlew test --tests "GildedRoseTest" --continue --info 2>&1)
TEST_EXIT_CODE=$?

# Generate coverage report regardless of test results
COVERAGE_OUTPUT=$(./gradlew jacocoTestReport --info 2>&1)

# Record end time
END_TIME=$(date +%s.%3N)
EXECUTION_TIME=$(echo "$END_TIME - $START_TIME" | bc)

# Re-enable exit on error
set -e

# Parse test results from output
TESTS_RUN=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ tests\? completed' | head -1 | grep -o '[0-9]\+' | head -1)
TESTS_FAILED=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ failed' | head -1 | grep -o '[0-9]\+' | head -1)

# Set defaults if parsing fails
TESTS_RUN=${TESTS_RUN:-1}
TESTS_FAILED=${TESTS_FAILED:-0}
TESTS_PASSED=$((TESTS_RUN - TESTS_FAILED))

# Parse coverage information
COVERAGE_PERCENT="N/A"
if [ -f "build/reports/jacoco/test/html/index.html" ]; then
    COVERAGE_PERCENT=$(grep -o 'Total[^%]*[0-9]\+%' build/reports/jacoco/test/html/index.html | grep -o '[0-9]\+%' | head -1)
fi
if [ -z "$COVERAGE_PERCENT" ] || [ "$COVERAGE_PERCENT" = "N/A" ]; then
    # Try alternative parsing from XML report
    if [ -f "build/reports/jacoco/test/jacocoTestReport.xml" ]; then
        COVERAGE_PERCENT=$(grep -o 'type="INSTRUCTION".*covered="[0-9]*".*missed="[0-9]*"' build/reports/jacoco/test/jacocoTestReport.xml | head -1 | sed 's/.*covered="\([0-9]*\)".*missed="\([0-9]*\)".*/\1 \2/' | awk '{if($1+$2>0) printf "%.0f%%", $1*100/($1+$2); else print "0%"}')
    fi
fi
COVERAGE_PERCENT=${COVERAGE_PERCENT:-"N/A"}

# Display failed test details if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    echo "❌ Failed Test Details:"
    
    # Extract test method name
    TEST_METHOD=$(echo "$TEST_OUTPUT" | grep -o 'GildedRoseTest > [^(]*' | head -1 | sed 's/GildedRoseTest > //')
    
    # Extract assertion failure details from JUnit output
    EXPECTED=$(echo "$TEST_OUTPUT" | grep -o 'expected: <[^>]*>' | head -1)
    ACTUAL=$(echo "$TEST_OUTPUT" | grep -o 'but was: <[^>]*>' | head -1)
    
    if [ -n "$TEST_METHOD" ]; then
        echo "   Test: $TEST_METHOD"
    fi
    
    if [ -n "$EXPECTED" ] && [ -n "$ACTUAL" ]; then
        echo "   Expected: $(echo "$EXPECTED" | sed 's/expected: <\(.*\)>/\1/')"
        echo "   Actual: $(echo "$ACTUAL" | sed 's/but was: <\(.*\)>/\1/')"
    else
        # Try alternative patterns for assertion errors
        ASSERTION_LINE=$(echo "$TEST_OUTPUT" | grep -i "assertion" | head -1)
        if [ -n "$ASSERTION_LINE" ]; then
            echo "   $ASSERTION_LINE" | sed 's/^[[:space:]]*/   /'
        else
            # Fallback: show relevant failure lines
            echo "$TEST_OUTPUT" | grep -E "(FAILED|AssertionError|expected|actual|assertEquals)" | head -3 | sed 's/^/   /'
        fi
    fi
    echo
fi

# Display test summary
echo "📊 Test Results Summary:"
echo "   • Tests Run: $TESTS_RUN"
echo "   • Tests Passed: $TESTS_PASSED"
echo "   • Tests Failed: $TESTS_FAILED"
echo "   • Code Coverage: $COVERAGE_PERCENT"
echo "   • Execution Time: ${EXECUTION_TIME}s"
echo

