# Java Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the Java environment setup and runs only the main Gilded Rose test
# Usage: ./run-tests.ps1 [mutate]
#   mutate - Run mutation tests in addition to regular tests

param(
    [switch]$mutate
)

$ErrorActionPreference = "Stop"

# Parse command line arguments - handle both switch and positional parameters
$runMutationTests = $false
if ($mutate) {
    $runMutationTests = $true
} elseif ($args.Count -gt 0) {
    foreach ($arg in $args) {
        if ($arg -eq "mutate") {
            $runMutationTests = $true
        } else {
            Write-Host "Unknown argument: $arg"
            Write-Host "Usage: $($MyInvocation.MyCommand.Name) [mutate]"
            exit 1
        }
    }
}

# Check if we're in the correct directory
if (-not (Test-Path "build.gradle")) {
    Write-Host "❌ Error: build.gradle not found. Please run this script from the Java implementation directory."
    exit 1
}

# Check if Java is available
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "✅ Java found: $javaVersion"
} catch {
    Write-Host "❌ Error: Java is not installed or not in PATH"
    exit 1
}

# Check if gradlew is executable (Windows doesn't need chmod)
if (-not (Test-Path "./gradlew")) {
    Write-Host "❌ Error: gradlew not found"
    exit 1
}

# Verify project structure
if (-not (Test-Path "src/main/java/com/gildedrose")) {
    Write-Host "❌ Error: Main source directory not found"
    exit 1
}

if (-not (Test-Path "src/test/java/com/gildedrose")) {
    Write-Host "❌ Error: Test source directory not found"
    exit 1
}

# Build the project (without running tests)
try {
    & ./gradlew assemble -q
} catch {
    Write-Host "❌ Error: Build failed"
    exit 1
}

# Run only the main Gilded Rose test (excluding secret tests)
Write-Host "🧪 Running Gilded Rose tests..."

# Record start time
$startTime = Get-Date

# Capture test output and exit code with detailed info and coverage
$testOutput = & ./gradlew test --tests "GildedRoseTest" jacocoTestReport --info --continue 2>&1
$testExitCode = $LASTEXITCODE

# Record end time and calculate duration
$endTime = Get-Date
$executionTime = [math]::Round(($endTime - $startTime).TotalSeconds, 3)

# Parse test results from XML file (more reliable than console output)
if (Test-Path "build/test-results/test/TEST-com.gildedrose.GildedRoseTest.xml") {
    try {
        $xmlContent = Get-Content "build/test-results/test/TEST-com.gildedrose.GildedRoseTest.xml" -Raw -ErrorAction SilentlyContinue
        
        # Extract from XML: <testsuite name="..." tests="18" skipped="0" failures="0" errors="0" ...>
        if ($xmlContent -match 'tests="(\d+)"') { $testsRun = [int]$matches[1] } else { $testsRun = 0 }
        if ($xmlContent -match 'failures="(\d+)"') { $testsFailed = [int]$matches[1] } else { $testsFailed = 0 }
        if ($xmlContent -match 'errors="(\d+)"') { $testsErrors = [int]$matches[1] } else { $testsErrors = 0 }
        if ($xmlContent -match 'skipped="(\d+)"') { $testsSkipped = [int]$matches[1] } else { $testsSkipped = 0 }
        
        # Calculate passed tests
        $testsTotalFailed = $testsFailed + $testsErrors
        $testsPassed = $testsRun - $testsTotalFailed
    } catch {
        # Set defaults if XML parsing fails
        $testsRun = 0
        $testsFailed = 0
        $testsErrors = 0
        $testsSkipped = 0
        $testsTotalFailed = 0
        $testsPassed = 0
    }
} else {
    # Fallback to console output parsing if XML not available
    $testsRun = 0
    $testsFailed = 0
    $testsErrors = 0
    $testsSkipped = 0
    $testOutputString = $testOutput -join "`n"
    
    if ($testOutputString -match '(\d+) tests? completed') { $testsRun = [int]$matches[1] }
    if ($testOutputString -match '(\d+) failed') { $testsFailed = [int]$matches[1] }
    
    $testsTotalFailed = $testsFailed
    $testsPassed = $testsRun - $testsFailed
}

# Parse coverage information
$coveragePercent = "N/A"
if (Test-Path "build/reports/jacoco/test/html/index.html") {
    $htmlContent = Get-Content "build/reports/jacoco/test/html/index.html" -Raw
    if ($htmlContent -match 'Total.*?(\d+)%') {
        $coveragePercent = $matches[1] + "%"
    }
}
if ($coveragePercent -eq "N/A" -and (Test-Path "build/reports/jacoco/test/jacocoTestReport.xml")) {
    $xmlContent = Get-Content "build/reports/jacoco/test/jacocoTestReport.xml" -Raw
    if ($xmlContent -match 'type="INSTRUCTION".*?covered="(\d+)".*?missed="(\d+)"') {
        $covered = [int]$matches[1]
        $missed = [int]$matches[2]
        $total = $covered + $missed
        if ($total -gt 0) {
            $coveragePercent = [math]::Round(($covered * 100) / $total, 0).ToString() + "%"
        }
    }
}

# Display failed test details if any tests failed
if ($testsFailed -gt 0) {
    Write-Host "❌ Failed Test Details:"
    
    # Extract test method name
    if ($testOutputString -match 'GildedRoseTest > ([^(]*)') {
        $testMethod = $matches[1].Trim()
        Write-Host "   Test: $testMethod"
    }
    
    # Extract assertion failure details from JUnit output
    if ($testOutputString -match 'expected: <([^>]*)>') {
        $expected = $matches[1]
        Write-Host "   Expected: $expected"
        
        if ($testOutputString -match 'but was: <([^>]*)>') {
            $actual = $matches[1]
            Write-Host "   Actual: $actual"
        }
    } else {
        # Fallback: show relevant failure lines
        $failureLines = $testOutput | Where-Object { $_ -match "(FAILED|AssertionError|expected|actual|assertEquals)" } | Select-Object -First 3
        foreach ($line in $failureLines) {
            Write-Host "   $line"
        }
    }
    Write-Host ""
}

# Display test summary
Write-Host "📊 Test Results Summary:"
Write-Host "   • Tests Run: $testsRun"
Write-Host "   • Tests Passed: $testsPassed"
Write-Host "   • Tests Failed: $testsTotalFailed"
if ($testsSkipped -gt 0) {
    Write-Host "   • Tests Skipped: $testsSkipped"
}
Write-Host "   • Code Coverage: $coveragePercent"
Write-Host "   • Execution Time: ${executionTime}s"
Write-Host ""

# Run mutation tests if requested
if ($runMutationTests) {
    Write-Host "🧬 Running mutation tests..."
    
    # Record mutation test start time
    $mutationStartTime = Get-Date
    
    # Check if mutations report exists and get timestamp before running
    $mutationsReportBefore = $null
    if (Test-Path "build/reports/pitest/mutations.csv") {
        $mutationsReportBefore = (Get-Item "build/reports/pitest/mutations.csv" -ErrorAction SilentlyContinue).LastWriteTime
    }
    
    # Run PITest mutation testing
    $mutationOutput = & ./gradlew pitest --info 2>&1
    $mutationExitCode = $LASTEXITCODE
    
    # Check if mutations report was updated (indicates fresh run vs cached)
    $pitestRunType = "cached"
    if (Test-Path "build/reports/pitest/mutations.csv") {
        $mutationsReportAfter = (Get-Item "build/reports/pitest/mutations.csv" -ErrorAction SilentlyContinue).LastWriteTime
        if ($mutationsReportBefore -eq $null -or $mutationsReportAfter -gt $mutationsReportBefore) {
            $pitestRunType = "fresh"
        }
    } else {
        $pitestRunType = "fresh"
    }
    
    # Record mutation test end time and calculate duration
    $mutationEndTime = Get-Date
    $mutationExecutionTime = [math]::Round(($mutationEndTime - $mutationStartTime).TotalSeconds, 3)
    
    # Parse mutation test results from CSV file (more reliable than console output)
    if (Test-Path "build/reports/pitest/mutations.csv") {
        try {
            $csvContent = Get-Content "build/reports/pitest/mutations.csv" -ErrorAction SilentlyContinue
            $mutationsGenerated = $csvContent.Count
            $mutationsKilled = ($csvContent | Where-Object { $_ -match "KILLED" }).Count
            $mutationsSurvived = ($csvContent | Where-Object { $_ -match "SURVIVED" }).Count
            $mutationsTimeout = ($csvContent | Where-Object { $_ -match "TIMED_OUT" }).Count
            $mutationsNoCoverage = ($csvContent | Where-Object { $_ -match "NO_COVERAGE" }).Count
            
            # Calculate mutation score if we have data
            if ($mutationsGenerated -gt 0) {
                $mutationScore = [math]::Round(($mutationsKilled * 100) / $mutationsGenerated, 0).ToString() + "%"
            } else {
                $mutationScore = "N/A"
            }
            
            # Try to get line coverage from HTML report
            $mutationCoverage = "N/A"
            if (Test-Path "build/reports/pitest/index.html") {
                $htmlContent = Get-Content "build/reports/pitest/index.html" -Raw -ErrorAction SilentlyContinue
                if ($htmlContent -match 'Line Coverage.*?(\d+)%') {
                    $mutationCoverage = $matches[1] + "%"
                } elseif ($htmlContent -match '(\d+)% <div class="coverage_bar"') {
                    $mutationCoverage = $matches[1] + "%"
                }
            }
        } catch {
            # Set defaults if CSV parsing fails
            $mutationsGenerated = 0
            $mutationsKilled = 0
            $mutationsSurvived = 0
            $mutationsTimeout = 0
            $mutationsNoCoverage = 0
            $mutationScore = "N/A"
            $mutationCoverage = "N/A"
        }
    } else {
        # Fallback to console output parsing if CSV not available
        $mutationOutputString = $mutationOutput -join "`n"
        $mutationsGenerated = 0
        $mutationsKilled = 0
        $mutationsSurvived = 0
        $mutationsTimeout = 0
        $mutationsNoCoverage = 0
        $mutationCoverage = "N/A"
        $mutationScore = "N/A"
        
        if ($mutationOutputString -match '(\d+) mutations generated') { $mutationsGenerated = [int]$matches[1] }
        if ($mutationOutputString -match '(\d+) killed') { $mutationsKilled = [int]$matches[1] }
        if ($mutationOutputString -match '(\d+) survived') { $mutationsSurvived = [int]$matches[1] }
        if ($mutationOutputString -match '(\d+)% line coverage') { $mutationCoverage = $matches[1] + "%" }
        if ($mutationOutputString -match '(\d+)% mutation coverage') { $mutationScore = $matches[1] + "%" }
    }
    
    # Display mutation test results
    Write-Host "🧬 Mutation Test Results Summary:"
    if ($pitestRunType -eq "cached") {
        Write-Host "   • Status: Using cached results (no source changes detected)"
    } else {
        Write-Host "   • Status: Fresh mutation analysis completed"
    }
    Write-Host "   • Mutations Generated: $mutationsGenerated"
    Write-Host "   • Mutations Killed: $mutationsKilled"
    Write-Host "   • Mutations Survived: $mutationsSurvived"
    if ($mutationsTimeout -gt 0 -or $mutationsNoCoverage -gt 0) {
        Write-Host "   • Mutations Timeout: $mutationsTimeout"
        Write-Host "   • Mutations No Coverage: $mutationsNoCoverage"
    }
    Write-Host "   • Line Coverage: $mutationCoverage"
    Write-Host "   • Mutation Score: $mutationScore"
    Write-Host "   • Mutation Test Time: ${mutationExecutionTime}s"
    Write-Host ""
    
    # Show mutation test report location
    if (Test-Path "build/reports/pitest/index.html") {
        Write-Host "📋 Mutation test report available at: build/reports/pitest/index.html"
        Write-Host ""
    }
    
    # Display survived mutations warning if any
    if ($mutationsSurvived -gt 0) {
        Write-Host "⚠️  Some mutations survived - consider improving test quality"
        Write-Host "   Review the mutation test report for details on uncaught mutations"
        Write-Host ""
    }
}