#!/bin/bash

# Python Gilded Rose Environment Verification Script
# This script verifies the Python environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

if [ ! -f "gilded_rose.py" ]; then
    echo "❌ Error: gilded_rose.py not found. Please run this script from the Python implementation directory."
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed or not in PATH"
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
echo "✅ Python found: $PYTHON_VERSION"

# Check for virtual environment
if [ ! -d ".venv" ]; then
    echo "❌ Error: Virtual environment (.venv) not found"
    echo "Please create a virtual environment with: python3 -m venv .venv"
    exit 1
fi

source .venv/bin/activate

# Check if pytest is installed
if ! python -c "import pytest" 2>/dev/null; then
    echo "❌ Error: pytest is not installed in the virtual environment"
    echo "Please install requirements with: pip install -r requirements.txt"
    exit 1
fi

if [ ! -f "test_gilded_rose.py" ]; then
    echo "❌ Error: Main test file (test_gilded_rose.py) not found"
    exit 1
fi

echo "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Temporarily disable exit on error for test execution
set +e

# Record start time
START_TIME=$(date +%s.%3N)

# Run only the main test file with coverage, excluding secret test files
TEST_OUTPUT=$(pytest test_gilded_rose.py --cov=gilded_rose --cov-report=term-missing --tb=short -v 2>&1)
TEST_EXIT_CODE=$?

# Record end time
END_TIME=$(date +%s.%3N)
EXECUTION_TIME=$(echo "$END_TIME - $START_TIME" | bc)

# Re-enable exit on error
set -e

# Parse test results from pytest output
TESTS_PASSED=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ passed' | grep -o '[0-9]\+' | head -1)
TESTS_FAILED=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ failed' | grep -o '[0-9]\+' | head -1)
TESTS_ERROR=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ error' | grep -o '[0-9]\+' | head -1)

# Set defaults if parsing fails
TESTS_PASSED=${TESTS_PASSED:-0}
TESTS_FAILED=${TESTS_FAILED:-0}
TESTS_ERROR=${TESTS_ERROR:-0}
TESTS_TOTAL=$((TESTS_PASSED + TESTS_FAILED + TESTS_ERROR))

# Parse coverage information
COVERAGE_PERCENT=$(echo "$TEST_OUTPUT" | grep -o 'TOTAL.*[0-9]\+%' | grep -o '[0-9]\+%' | head -1)
COVERAGE_PERCENT=${COVERAGE_PERCENT:-"N/A"}

# Display failed test details if any tests failed
if [ $TESTS_FAILED -gt 0 ] || [ $TESTS_ERROR -gt 0 ]; then
    echo "❌ Failed Test Details:"
    echo "$TEST_OUTPUT" | grep -E "(FAILED|ERROR|AssertionError)" | head -5 | sed 's/^/   /'
    echo
fi

# Display test summary
echo "📊 Test Results Summary:"
echo "   • Tests Run: $TESTS_TOTAL"
echo "   • Tests Passed: $TESTS_PASSED"
echo "   • Tests Failed: $((TESTS_FAILED + TESTS_ERROR))"
echo "   • Code Coverage: $COVERAGE_PERCENT"
echo "   • Execution Time: ${EXECUTION_TIME}s"
echo

# Deactivate virtual environment
deactivate
