#!/bin/bash

# .NET Gilded Rose Environment Verification Script
# This script verifies the .NET environment setup and runs only the main Gilded Rose test
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
if [ ! -f "GildedRose/GildedRose.csproj" ]; then
    echo "❌ Error: GildedRose.csproj not found"
    exit 1
fi

if [ ! -f "Tests/Tests.csproj" ]; then
    echo "❌ Error: Tests.csproj not found"
    exit 1
fi

# Run all Gilded Rose tests
echo "🧪 Running Gilded Rose tests..."

# Change to Tests directory and run only GildedRoseTest
cd Tests

# Temporarily disable exit on error for test execution
set +e

# Record start time
START_TIME=$(date +%s.%3N)

# Run tests excluding any with "Secret" in the name, capture output
TEST_OUTPUT=$(dotnet test --collect:"XPlat Code Coverage" --verbosity normal --nologo 2>&1)
TEST_EXIT_CODE=$?

# Record end time
END_TIME=$(date +%s.%3N)
EXECUTION_TIME=$(echo "$END_TIME - $START_TIME" | bc)

# Re-enable exit on error
set -e

# Parse test results from output
TESTS_TOTAL=$(echo "$TEST_OUTPUT" | grep -o 'Total tests: [0-9]\+' | grep -o '[0-9]\+' | head -1)
TESTS_PASSED=$(echo "$TEST_OUTPUT" | grep -o 'Passed: [0-9]\+' | grep -o '[0-9]\+' | head -1)
TESTS_FAILED=$(echo "$TEST_OUTPUT" | grep -o 'Failed: [0-9]\+' | grep -o '[0-9]\+' | head -1)

# Alternative parsing for different output formats
if [ -z "$TESTS_TOTAL" ]; then
    TESTS_TOTAL=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ test[s]*' | grep -o '[0-9]\+' | head -1)
fi
if [ -z "$TESTS_PASSED" ]; then
    TESTS_PASSED=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ passed' | grep -o '[0-9]\+' | head -1)
fi
if [ -z "$TESTS_FAILED" ]; then
    TESTS_FAILED=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ failed' | grep -o '[0-9]\+' | head -1)
fi

# Set defaults if parsing fails
TESTS_TOTAL=${TESTS_TOTAL:-0}
TESTS_PASSED=${TESTS_PASSED:-0}
TESTS_FAILED=${TESTS_FAILED:-0}

# Calculate if values are missing
if [ "$TESTS_TOTAL" -eq 0 ] && [ "$TESTS_PASSED" -gt 0 ]; then
    TESTS_TOTAL=$((TESTS_PASSED + TESTS_FAILED))
fi
if [ "$TESTS_PASSED" -eq 0 ] && [ "$TESTS_TOTAL" -gt 0 ]; then
    TESTS_PASSED=$((TESTS_TOTAL - TESTS_FAILED))
fi

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

# Go back to root directory for mutation testing
cd ..

# Run mutation tests if requested
if [ "$RUN_MUTATION_TESTS" = true ]; then
    echo "🧬 Running mutation tests with Stryker..."
    
    # Record mutation test start time
    MUTATION_START_TIME=$(date +%s.%3N)
    
    # Temporarily disable exit on error for mutation test execution
    set +e
    
    # Run Stryker mutation testing and wait for completion
    dotnet stryker --config-file stryker-config.json
    MUTATION_EXIT_CODE=$?
    
    # Record mutation test end time
    MUTATION_END_TIME=$(date +%s.%3N)
    MUTATION_EXECUTION_TIME=$(echo "$MUTATION_END_TIME - $MUTATION_START_TIME" | bc)
    
    # Re-enable exit on error
    set -e
    
    # Parse mutation test results from JSON output (more reliable than console parsing)
    LATEST_JSON_REPORT=""
    if [ -d "StrykerOutput" ]; then
        LATEST_JSON_REPORT=$(find StrykerOutput -name "mutation-report.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
        # Fallback if printf not available
        if [ -z "$LATEST_JSON_REPORT" ]; then
            LATEST_JSON_REPORT=$(find StrykerOutput -name "mutation-report.json" -type f | sort | tail -1)
        fi
    fi
    
    if [ -n "$LATEST_JSON_REPORT" ] && [ -f "$LATEST_JSON_REPORT" ]; then
        echo "📊 Parsing results from JSON report: $LATEST_JSON_REPORT"
        
        # Use jq if available, otherwise fall back to basic parsing
        if command -v jq >/dev/null 2>&1; then
            MUTATIONS_KILLED=$(jq -r '.files | to_entries[] | .value.mutants[] | select(.status == "Killed") | 1' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATIONS_SURVIVED=$(jq -r '.files | to_entries[] | .value.mutants[] | select(.status == "Survived") | 1' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATIONS_TIMEOUT=$(jq -r '.files | to_entries[] | .value.mutants[] | select(.status == "Timeout") | 1' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATIONS_IGNORED=$(jq -r '.files | to_entries[] | .value.mutants[] | select(.status == "Ignored") | 1' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATIONS_NOCOVERAGE=$(jq -r '.files | to_entries[] | .value.mutants[] | select(.status == "NoCoverage") | 1' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATION_SCORE=$(jq -r '.thresholds.high // empty' "$LATEST_JSON_REPORT" 2>/dev/null)
            
            # Try to get actual mutation score from summary if available
            if [ -z "$MUTATION_SCORE" ] || [ "$MUTATION_SCORE" = "null" ]; then
                MUTATION_SCORE=$(jq -r '.mutationScore // empty' "$LATEST_JSON_REPORT" 2>/dev/null)
            fi
        else
            # Fallback parsing without jq
            MUTATIONS_KILLED=$(grep -o '"status":"Killed"' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATIONS_SURVIVED=$(grep -o '"status":"Survived"' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATIONS_TIMEOUT=$(grep -o '"status":"Timeout"' "$LATEST_JSON_REPORT" 2>/dev/null | wc -l)
            MUTATION_SCORE=""
        fi
    else
        echo "⚠️  JSON report not found. Unable to parse mutation results."
        MUTATIONS_KILLED=0
        MUTATIONS_SURVIVED=0
        MUTATIONS_TIMEOUT=0
        MUTATION_SCORE=""
    fi
    
    # Set defaults and calculate totals
    MUTATIONS_KILLED=${MUTATIONS_KILLED:-0}
    MUTATIONS_SURVIVED=${MUTATIONS_SURVIVED:-0}
    MUTATIONS_TIMEOUT=${MUTATIONS_TIMEOUT:-0}
    MUTATIONS_IGNORED=${MUTATIONS_IGNORED:-0}
    MUTATIONS_NOCOVERAGE=${MUTATIONS_NOCOVERAGE:-0}
    MUTATIONS_TESTED=$((MUTATIONS_KILLED + MUTATIONS_SURVIVED + MUTATIONS_TIMEOUT))
    
    # Calculate mutation score if not already set
    if [ -z "$MUTATION_SCORE" ] || [ "$MUTATION_SCORE" = "null" ]; then
        if [ "$MUTATIONS_TESTED" -gt 0 ]; then
            MUTATION_SCORE=$(echo "scale=2; $MUTATIONS_KILLED * 100 / $MUTATIONS_TESTED" | bc -l 2>/dev/null || echo "0")
            MUTATION_SCORE="${MUTATION_SCORE}%"
        else
            MUTATION_SCORE="N/A"
        fi
    elif [ -n "$MUTATION_SCORE" ] && [[ ! "$MUTATION_SCORE" =~ % ]]; then
        MUTATION_SCORE="${MUTATION_SCORE}%"
    fi
    
    # Final fallback defaults
    MUTATIONS_TESTED=${MUTATIONS_TESTED:-0}
    MUTATIONS_KILLED=${MUTATIONS_KILLED:-0}
    MUTATIONS_SURVIVED=${MUTATIONS_SURVIVED:-0}
    MUTATIONS_TIMEOUT=${MUTATIONS_TIMEOUT:-0}
    MUTATION_SCORE=${MUTATION_SCORE:-"N/A"}
    
    # Display mutation test results
    echo "🧬 Mutation Test Results Summary:"
    echo "   • Mutations Tested: $MUTATIONS_TESTED"
    echo "   • Mutations Killed: $MUTATIONS_KILLED"
    echo "   • Mutations Survived: $MUTATIONS_SURVIVED"
    echo "   • Mutations Timeout: $MUTATIONS_TIMEOUT"
    if [ "$MUTATIONS_IGNORED" -gt 0 ] || [ "$MUTATIONS_NOCOVERAGE" -gt 0 ]; then
        echo "   • Mutations Ignored: $MUTATIONS_IGNORED"
        echo "   • Mutations No Coverage: $MUTATIONS_NOCOVERAGE"
    fi
    echo "   • Mutation Score: $MUTATION_SCORE"
    echo "   • Mutation Test Time: ${MUTATION_EXECUTION_TIME}s"
    echo
    
    # Show mutation test report location
    if [ -d "StrykerOutput" ]; then
        LATEST_REPORT=$(find StrykerOutput -name "mutation-report.html" | head -1)
        if [ -n "$LATEST_REPORT" ]; then
            echo "📋 Mutation test report available at: $LATEST_REPORT"
            echo
        fi
    fi
    
    # Display survived mutations warning if any
    if [ "$MUTATIONS_SURVIVED" -gt 0 ] && [ "$MUTATIONS_SURVIVED" != "0" ]; then
        echo "⚠️  Some mutations survived - consider improving test quality"
        echo "   Review the mutation test report for details on uncaught mutations"
        echo
    fi
fi