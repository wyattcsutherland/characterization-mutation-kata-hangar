#!/bin/bash

# Java Gilded Rose Environment Verification Script
# This script verifies the Java environment setup and runs only the main Gilded Rose test
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

# Parse test results from XML file (more reliable than console output)
if [ -f "build/test-results/test/TEST-com.gildedrose.GildedRoseTest.xml" ]; then
    # Extract from XML: <testsuite name="..." tests="18" skipped="0" failures="0" errors="0" ...>
    TESTS_RUN=$(grep -o 'tests="[0-9]\+"' build/test-results/test/TEST-com.gildedrose.GildedRoseTest.xml | grep -o '[0-9]\+' | head -1)
    TESTS_FAILED=$(grep -o 'failures="[0-9]\+"' build/test-results/test/TEST-com.gildedrose.GildedRoseTest.xml | grep -o '[0-9]\+' | head -1)
    TESTS_ERRORS=$(grep -o 'errors="[0-9]\+"' build/test-results/test/TEST-com.gildedrose.GildedRoseTest.xml | grep -o '[0-9]\+' | head -1)
    TESTS_SKIPPED=$(grep -o 'skipped="[0-9]\+"' build/test-results/test/TEST-com.gildedrose.GildedRoseTest.xml | grep -o '[0-9]\+' | head -1)
    
    # Clean variables
    TESTS_RUN=$(echo "$TESTS_RUN" | tr -d '\n\r' | xargs)
    TESTS_FAILED=$(echo "$TESTS_FAILED" | tr -d '\n\r' | xargs)
    TESTS_ERRORS=$(echo "$TESTS_ERRORS" | tr -d '\n\r' | xargs)
    TESTS_SKIPPED=$(echo "$TESTS_SKIPPED" | tr -d '\n\r' | xargs)
    
    # Set defaults if parsing fails
    TESTS_RUN=${TESTS_RUN:-0}
    TESTS_FAILED=${TESTS_FAILED:-0}
    TESTS_ERRORS=${TESTS_ERRORS:-0}
    TESTS_SKIPPED=${TESTS_SKIPPED:-0}
    
    # Calculate passed tests
    TESTS_TOTAL_FAILED=$((TESTS_FAILED + TESTS_ERRORS))
    TESTS_PASSED=$((TESTS_RUN - TESTS_TOTAL_FAILED))
else
    # Fallback to console output parsing if XML not available
    TESTS_RUN=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ tests\? completed' | head -1 | grep -o '[0-9]\+' | head -1)
    TESTS_FAILED=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ failed' | head -1 | grep -o '[0-9]\+' | head -1)
    
    # Set defaults if parsing fails
    TESTS_RUN=${TESTS_RUN:-0}
    TESTS_FAILED=${TESTS_FAILED:-0}
    TESTS_ERRORS=0
    TESTS_SKIPPED=0
    TESTS_TOTAL_FAILED=$TESTS_FAILED
    TESTS_PASSED=$((TESTS_RUN - TESTS_FAILED))
fi

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
echo "   • Tests Failed: $TESTS_TOTAL_FAILED"
if [ "$TESTS_SKIPPED" -gt 0 ]; then
    echo "   • Tests Skipped: $TESTS_SKIPPED"
fi
echo "   • Code Coverage: $COVERAGE_PERCENT"
echo "   • Execution Time: ${EXECUTION_TIME}s"
echo

# Run mutation tests if requested
if [ "$RUN_MUTATION_TESTS" = true ]; then
    echo "🧬 Running mutation tests..."
    
    # Record mutation test start time
    MUTATION_START_TIME=$(date +%s.%3N)
    
    # Temporarily disable exit on error for mutation test execution
    set +e
    
    # Check if mutations report exists and get timestamp before running
    MUTATIONS_REPORT_BEFORE=""
    if [ -f "build/reports/pitest/mutations.csv" ]; then
        MUTATIONS_REPORT_BEFORE=$(stat -c %Y "build/reports/pitest/mutations.csv" 2>/dev/null || echo "0")
    fi
    
    # Run PITest mutation testing
    MUTATION_OUTPUT=$(./gradlew pitest --info 2>&1)
    MUTATION_EXIT_CODE=$?
    
    # Check if mutations report was updated (indicates fresh run vs cached)
    MUTATIONS_REPORT_AFTER=""
    PITEST_RUN_TYPE="cached"
    if [ -f "build/reports/pitest/mutations.csv" ]; then
        MUTATIONS_REPORT_AFTER=$(stat -c %Y "build/reports/pitest/mutations.csv" 2>/dev/null || echo "0")
        if [ "$MUTATIONS_REPORT_BEFORE" != "$MUTATIONS_REPORT_AFTER" ]; then
            PITEST_RUN_TYPE="fresh"
        fi
    else
        PITEST_RUN_TYPE="fresh"
    fi
    
    # Record mutation test end time
    MUTATION_END_TIME=$(date +%s.%3N)
    MUTATION_EXECUTION_TIME=$(echo "$MUTATION_END_TIME - $MUTATION_START_TIME" | bc)
    
    # Re-enable exit on error
    set -e
    
    # Parse mutation test results from CSV file (more reliable than console output)
    if [ -f "build/reports/pitest/mutations.csv" ]; then
        MUTATIONS_GENERATED=$(wc -l < build/reports/pitest/mutations.csv 2>/dev/null || echo "0")
        MUTATIONS_KILLED=$(grep -c "KILLED" build/reports/pitest/mutations.csv 2>/dev/null || echo "0")
        MUTATIONS_SURVIVED=$(grep -c "SURVIVED" build/reports/pitest/mutations.csv 2>/dev/null || echo "0")
        MUTATIONS_TIMEOUT=$(grep -c "TIMED_OUT" build/reports/pitest/mutations.csv 2>/dev/null || echo "0")
        MUTATIONS_NO_COVERAGE=$(grep -c "NO_COVERAGE" build/reports/pitest/mutations.csv 2>/dev/null || echo "0")
        
        # Clean variables of whitespace/newlines
        MUTATIONS_GENERATED=$(echo "$MUTATIONS_GENERATED" | tr -d '\n\r' | xargs)
        MUTATIONS_KILLED=$(echo "$MUTATIONS_KILLED" | tr -d '\n\r' | xargs)
        MUTATIONS_SURVIVED=$(echo "$MUTATIONS_SURVIVED" | tr -d '\n\r' | xargs)
        MUTATIONS_TIMEOUT=$(echo "$MUTATIONS_TIMEOUT" | tr -d '\n\r' | xargs)
        MUTATIONS_NO_COVERAGE=$(echo "$MUTATIONS_NO_COVERAGE" | tr -d '\n\r' | xargs)
        
        # Calculate mutation score if we have data
        if [ "$MUTATIONS_GENERATED" -gt 0 ]; then
            MUTATION_SCORE=$(awk "BEGIN {printf \"%.0f%%\", ($MUTATIONS_KILLED * 100) / $MUTATIONS_GENERATED}")
        else
            MUTATION_SCORE="N/A"
        fi
        
        # Try to get line coverage from HTML report
        MUTATION_COVERAGE="N/A"
        if [ -f "build/reports/pitest/index.html" ]; then
            MUTATION_COVERAGE=$(grep -o 'Line Coverage.*[0-9]\+%' build/reports/pitest/index.html | head -1 | grep -o '[0-9]\+%' | head -1)
            if [ -z "$MUTATION_COVERAGE" ]; then
                # Try alternative HTML parsing
                MUTATION_COVERAGE=$(grep -o '[0-9]\+% <div class="coverage_bar"' build/reports/pitest/index.html | head -1 | grep -o '[0-9]\+%' | head -1)
            fi
        fi
        MUTATION_COVERAGE=${MUTATION_COVERAGE:-"N/A"}
    else
        # Fallback to console output parsing if CSV not available
        MUTATIONS_GENERATED=$(echo "$MUTATION_OUTPUT" | grep -o '[0-9]\+ mutations generated' | head -1 | grep -o '[0-9]\+' | head -1)
        MUTATIONS_KILLED=$(echo "$MUTATION_OUTPUT" | grep -o '[0-9]\+ killed' | head -1 | grep -o '[0-9]\+' | head -1)
        MUTATIONS_SURVIVED=$(echo "$MUTATION_OUTPUT" | grep -o '[0-9]\+ survived' | head -1 | grep -o '[0-9]\+' | head -1)
        MUTATIONS_TIMEOUT="0"
        MUTATIONS_NO_COVERAGE="0"
        MUTATION_COVERAGE=$(echo "$MUTATION_OUTPUT" | grep -o '[0-9]\+% line coverage' | head -1 | grep -o '[0-9]\+%' | head -1)
        MUTATION_SCORE=$(echo "$MUTATION_OUTPUT" | grep -o '[0-9]\+% mutation coverage' | head -1 | grep -o '[0-9]\+%' | head -1)
        
        # Set defaults if parsing fails
        MUTATIONS_GENERATED=${MUTATIONS_GENERATED:-0}
        MUTATIONS_KILLED=${MUTATIONS_KILLED:-0}
        MUTATIONS_SURVIVED=${MUTATIONS_SURVIVED:-0}
        MUTATION_COVERAGE=${MUTATION_COVERAGE:-"N/A"}
        MUTATION_SCORE=${MUTATION_SCORE:-"N/A"}
    fi
    
    # Display mutation test results
    echo "🧬 Mutation Test Results Summary:"
    if [ "$PITEST_RUN_TYPE" = "cached" ]; then
        echo "   • Status: Using cached results (no source changes detected)"
    else
        echo "   • Status: Fresh mutation analysis completed"
    fi
    echo "   • Mutations Generated: $MUTATIONS_GENERATED"
    echo "   • Mutations Killed: $MUTATIONS_KILLED"
    echo "   • Mutations Survived: $MUTATIONS_SURVIVED"
    # Only show timeout and no-coverage if they have meaningful values
    SHOW_EXTRA_STATS=false
    if [ -n "$MUTATIONS_TIMEOUT" ] && [ "$MUTATIONS_TIMEOUT" -gt 0 ] 2>/dev/null; then
        SHOW_EXTRA_STATS=true
    fi
    if [ -n "$MUTATIONS_NO_COVERAGE" ] && [ "$MUTATIONS_NO_COVERAGE" -gt 0 ] 2>/dev/null; then
        SHOW_EXTRA_STATS=true
    fi
    
    if [ "$SHOW_EXTRA_STATS" = true ]; then
        echo "   • Mutations Timeout: ${MUTATIONS_TIMEOUT:-0}"
        echo "   • Mutations No Coverage: ${MUTATIONS_NO_COVERAGE:-0}"
    fi
    echo "   • Line Coverage: $MUTATION_COVERAGE"
    echo "   • Mutation Score: $MUTATION_SCORE"
    echo "   • Mutation Test Time: ${MUTATION_EXECUTION_TIME}s"
    echo
    
    # Show mutation test report location
    if [ -f "build/reports/pitest/index.html" ]; then
        echo "📋 Mutation test report available at: build/reports/pitest/index.html"
        echo
    fi
    
    # Display survived mutations if any
    if [ "$MUTATIONS_SURVIVED" -gt 0 ] && [ "$MUTATIONS_SURVIVED" != "0" ]; then
        echo "⚠️  Some mutations survived - consider improving test quality"
        echo "   Review the mutation test report for details on uncaught mutations"
        echo
    fi
fi

