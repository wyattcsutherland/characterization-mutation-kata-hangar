#!/bin/bash

# .NET Gilded Rose Environment Verification Script
# This script verifies the .NET environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

# Check if we're in the correct directory
if [ ! -f "stryker-config.json" ]; then
    echo "❌ Error: stryker-config.json not found. Please run this script from the .NET implementation directory."
    exit 1
fi

# Check if dotnet is available
if ! command -v dotnet &> /dev/null; then
    echo "❌ Error: .NET is not installed or not in PATH"
    exit 1
fi

DOTNET_VERSION=$(dotnet --version)
echo "✅ .NET found: $DOTNET_VERSION"

# Verify project structure
if [ ! -d "GildedRose" ]; then
    echo "❌ Error: GildedRose project directory not found"
    exit 1
fi

if [ ! -d "Tests" ]; then
    echo "❌ Error: Tests project directory not found"
    exit 1
fi

# Run only the main Gilded Rose test (excluding secret tests)
echo "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Change to Tests directory and run only GildedRoseTest
cd Tests

# Temporarily disable exit on error for test execution
set +e

# Record start time
START_TIME=$(date +%s.%3N)

# Run tests excluding any with "Secret" in the name, capture output
TEST_OUTPUT=$(dotnet test --filter "FullyQualifiedName~GildedRoseTest&FullyQualifiedName!~Secret" --collect:"XPlat Code Coverage" --verbosity normal --nologo 2>&1)
TEST_EXIT_CODE=$?

# Record end time
END_TIME=$(date +%s.%3N)
EXECUTION_TIME=$(echo "$END_TIME - $START_TIME" | bc)

# Re-enable exit on error
set -e

# Parse test results from output
TESTS_RUN=$(echo "$TEST_OUTPUT" | grep -o 'Passed: [0-9]\+' | grep -o '[0-9]\+' | head -1)
TESTS_FAILED=$(echo "$TEST_OUTPUT" | grep -o 'Failed: [0-9]\+' | grep -o '[0-9]\+' | head -1)
TESTS_TOTAL=$(echo "$TEST_OUTPUT" | grep -o 'Total: [0-9]\+' | grep -o '[0-9]\+' | head -1)

# Alternative parsing for different output formats
if [ -z "$TESTS_RUN" ]; then
    TESTS_RUN=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ passed' | grep -o '[0-9]\+' | head -1)
fi
if [ -z "$TESTS_FAILED" ]; then
    TESTS_FAILED=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ failed' | grep -o '[0-9]\+' | head -1)
fi
if [ -z "$TESTS_TOTAL" ]; then
    TESTS_TOTAL=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ test[s]*' | grep -o '[0-9]\+' | head -1)
fi

# Set defaults if parsing fails
TESTS_RUN=${TESTS_RUN:-1}
TESTS_FAILED=${TESTS_FAILED:-0}
TESTS_TOTAL=${TESTS_TOTAL:-$TESTS_RUN}
TESTS_PASSED=$((TESTS_TOTAL - TESTS_FAILED))

# Parse coverage information
COVERAGE_PERCENT="N/A"
COVERAGE_FILE=$(find TestResults -name "coverage.cobertura.xml" 2>/dev/null | head -1)
if [ -n "$COVERAGE_FILE" ] && [ -f "$COVERAGE_FILE" ]; then
    COVERAGE_PERCENT=$(grep -o 'line-rate="[0-9.]*"' "$COVERAGE_FILE" | head -1 | grep -o '[0-9.]*' | awk '{printf "%.0f%%", $1*100}')
fi

# Display failed test details if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    echo "❌ Failed Test Details:"
    echo "$TEST_OUTPUT" | grep -E "(FAIL|Failed|Error)" | head -5 | sed 's/^/   /'
    echo
fi

# Display test summary
echo "📊 Test Results Summary:"
echo "   • Tests Run: $TESTS_TOTAL"
echo "   • Tests Passed: $TESTS_PASSED"
echo "   • Tests Failed: $TESTS_FAILED"
echo "   • Code Coverage: $COVERAGE_PERCENT"
echo "   • Execution Time: ${EXECUTION_TIME}s"
echo