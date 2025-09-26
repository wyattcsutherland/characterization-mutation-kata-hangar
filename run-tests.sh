#!/bin/bash

# Python Gilded Rose Environment Verification Script
# This script verifies the Python environment setup and runs only the main Gilded Rose test
# Usage: ./run-tests.sh [mutate]
#   mutate - Run mutation tests in addition to regular tests

set -e  # Exit on any error

# Parse command line arguments
RUN_MUTATION_TESTS=false
for arg in "$@"; do
    case $arg in
        mutate)
            RUN_MUTATION_TESTS=true
            shift
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [mutate]"
            exit 1
            ;;
    esac
done

if [ ! -f "src/gilded_rose.py" ]; then
    echo "❌ Error: src/gilded_rose.py not found. Please run this script from the Python implementation directory."
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

if [ ! -f "src/test_gilded_rose.py" ]; then
    echo "❌ Error: Main test file (src/test_gilded_rose.py) not found"
    exit 1
fi

echo "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Temporarily disable exit on error for test execution
set +e

# Record start time
START_TIME=$(date +%s.%3N)

# Run only the main test file with coverage, excluding secret test files
TEST_OUTPUT=$(cd src && python -m pytest test_gilded_rose.py --cov=gilded_rose --cov-report=term-missing --tb=short -v 2>&1)
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

# Run mutation tests if requested
if [ "$RUN_MUTATION_TESTS" = true ]; then
    echo "🧬 Running mutation tests with mutmut..."
    
    # Record mutation test start time
    MUTATION_START_TIME=$(date +%s.%3N)
    
    # Temporarily disable exit on error for mutation test execution
    set +e
    
    # Check if mutmut is installed
    if ! python -c "import mutmut" 2>/dev/null; then
        echo "❌ Error: mutmut is not installed in the virtual environment"
        echo "Please install mutmut with: pip install mutmut"
        exit 1
    fi
    
    # Run mutmut mutation testing (cd to src directory to avoid src. module name issues)
    cd src
    MUTATION_OUTPUT=$(mutmut run --max-children 2 2>&1)
    MUTATION_EXIT_CODE=$?
    cd ..
    
    # Record mutation test end time
    MUTATION_END_TIME=$(date +%s.%3N)
    MUTATION_EXECUTION_TIME=$(echo "$MUTATION_END_TIME - $MUTATION_START_TIME" | bc)
    
    # Re-enable exit on error
    set -e
    
    # Parse mutation test results from mutmut output
    # Always try to get results using mutmut results command for most accurate counts
    cd src
    RESULTS_OUTPUT=$(mutmut results --all True 2>/dev/null || echo "")
    cd ..
    
    if [ -n "$RESULTS_OUTPUT" ]; then
        MUTATIONS_GENERATED=$(echo "$RESULTS_OUTPUT" | wc -l)
        MUTATIONS_KILLED=$(echo "$RESULTS_OUTPUT" | grep -c ": killed" 2>/dev/null || echo "0")
        MUTATIONS_SURVIVED=$(echo "$RESULTS_OUTPUT" | grep -c ": survived" 2>/dev/null || echo "0")
        MUTATIONS_SKIPPED=$(echo "$RESULTS_OUTPUT" | grep -c ": no tests" 2>/dev/null || echo "0")
        MUTATIONS_TIMEOUT=$(echo "$RESULTS_OUTPUT" | grep -c ": timeout" 2>/dev/null || echo "0")
        MUTATIONS_SUSPICIOUS=$(echo "$RESULTS_OUTPUT" | grep -c ": suspicious" 2>/dev/null || echo "0")
    elif [ -n "$(echo "$MUTATION_OUTPUT" | grep -E '[0-9]+/[0-9]+.*🎉.*🫥.*⏰.*🤔.*🙁')" ]; then
        # Fallback to parsing console output summary line
        SUMMARY_LINE=$(echo "$MUTATION_OUTPUT" | grep -E '[0-9]+/[0-9]+.*🎉.*🫥.*⏰.*🤔.*🙁' | tail -1)
        MUTATIONS_GENERATED=$(echo "$SUMMARY_LINE" | grep -o '[0-9]\+/[0-9]\+' | cut -d'/' -f2 | head -1)
        MUTATIONS_KILLED=$(echo "$SUMMARY_LINE" | grep -o '🎉 [0-9]\+' | grep -o '[0-9]\+' | head -1)
        MUTATIONS_SKIPPED=$(echo "$SUMMARY_LINE" | grep -o '🫥 [0-9]\+' | grep -o '[0-9]\+' | head -1)
        MUTATIONS_TIMEOUT=$(echo "$SUMMARY_LINE" | grep -o '⏰ [0-9]\+' | grep -o '[0-9]\+' | head -1)
        MUTATIONS_SUSPICIOUS=$(echo "$SUMMARY_LINE" | grep -o '🤔 [0-9]\+' | grep -o '[0-9]\+' | head -1)
        MUTATIONS_SURVIVED=$(echo "$SUMMARY_LINE" | grep -o '🙁 [0-9]\+' | grep -o '[0-9]\+' | head -1)
    else
        # Final fallback - set default values
        MUTATIONS_GENERATED="0"
        MUTATIONS_KILLED="0"
        MUTATIONS_SURVIVED="0"
        MUTATIONS_TIMEOUT="0"
        MUTATIONS_SUSPICIOUS="0"
        MUTATIONS_SKIPPED="0"
    fi
    
    # Set defaults if parsing fails and clean up whitespace
    MUTATIONS_GENERATED=$(echo "${MUTATIONS_GENERATED:-0}" | tr -d '\n\r' | xargs)
    MUTATIONS_KILLED=$(echo "${MUTATIONS_KILLED:-0}" | tr -d '\n\r' | xargs)
    MUTATIONS_SURVIVED=$(echo "${MUTATIONS_SURVIVED:-0}" | tr -d '\n\r' | xargs)
    MUTATIONS_TIMEOUT=$(echo "${MUTATIONS_TIMEOUT:-0}" | tr -d '\n\r' | xargs)
    MUTATIONS_SUSPICIOUS=$(echo "${MUTATIONS_SUSPICIOUS:-0}" | tr -d '\n\r' | xargs)
    MUTATIONS_SKIPPED=$(echo "${MUTATIONS_SKIPPED:-0}" | tr -d '\n\r' | xargs)
    
    # Calculate mutation score if we have data
    if [ "$MUTATIONS_GENERATED" -gt 0 ] && [ "$MUTATIONS_KILLED" -ge 0 ]; then
        MUTATION_SCORE=$(awk "BEGIN {printf \"%.0f%%\", ($MUTATIONS_KILLED * 100) / $MUTATIONS_GENERATED}")
    else
        MUTATION_SCORE="N/A"
    fi
    
    # Calculate coverage from mutations that were tested (excluding skipped)
    MUTATIONS_TESTED=$((MUTATIONS_KILLED + MUTATIONS_SURVIVED + MUTATIONS_TIMEOUT + MUTATIONS_SUSPICIOUS))
    if [ "$MUTATIONS_TESTED" -gt 0 ] && [ "$MUTATIONS_GENERATED" -gt 0 ]; then
        MUTATION_COVERAGE=$(awk "BEGIN {printf \"%.0f%%\", ($MUTATIONS_TESTED * 100) / $MUTATIONS_GENERATED}")
    else
        MUTATION_COVERAGE="N/A"
    fi
    
    # Display mutation test results
    echo "🧬 Mutation Test Results Summary:"
    echo "   • Mutations Generated: $MUTATIONS_GENERATED"
    echo "   • Mutations Killed: $MUTATIONS_KILLED"
    echo "   • Mutations Survived: $MUTATIONS_SURVIVED"
    # Only show additional stats if they have meaningful values
    SHOW_EXTRA_STATS=false
    if [ "$MUTATIONS_TIMEOUT" -gt 0 ] 2>/dev/null; then
        SHOW_EXTRA_STATS=true
    fi
    if [ "$MUTATIONS_SUSPICIOUS" -gt 0 ] 2>/dev/null; then
        SHOW_EXTRA_STATS=true
    fi
    if [ "$MUTATIONS_SKIPPED" -gt 0 ] 2>/dev/null; then
        SHOW_EXTRA_STATS=true
    fi
    
    if [ "$SHOW_EXTRA_STATS" = true ]; then
        if [ "$MUTATIONS_TIMEOUT" -gt 0 ] 2>/dev/null; then
            echo "   • Mutations Timeout: $MUTATIONS_TIMEOUT"
        fi
        if [ "$MUTATIONS_SUSPICIOUS" -gt 0 ] 2>/dev/null; then
            echo "   • Mutations Suspicious: $MUTATIONS_SUSPICIOUS"
        fi
        if [ "$MUTATIONS_SKIPPED" -gt 0 ] 2>/dev/null; then
            echo "   • Mutations Skipped: $MUTATIONS_SKIPPED"
        fi
    fi
    echo "   • Mutation Coverage: $MUTATION_COVERAGE"
    echo "   • Mutation Score: $MUTATION_SCORE"
    echo "   • Mutation Test Time: ${MUTATION_EXECUTION_TIME}s"
    echo
    
    # Show how to browse results
    echo "📋 To view detailed mutation results, run: mutmut show"
    echo "📋 To view HTML report, run: mutmut html && open html/index.html"
    echo
    
    # Display survived mutations warning if any
    if [ "$MUTATIONS_SURVIVED" -gt 0 ] && [ "$MUTATIONS_SURVIVED" != "0" ]; then
        echo "⚠️  Some mutations survived - consider improving test quality"
        echo "   Run 'mutmut show <id>' to see specific survived mutations"
        echo
    fi
fi

# Deactivate virtual environment
deactivate
