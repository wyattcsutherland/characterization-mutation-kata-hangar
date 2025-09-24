# Java Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the Java environment setup and runs only the main Gilded Rose test

$ErrorActionPreference = "Stop"

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

# Parse test results from output
$testsRun = 1
$testsFailed = 0
$testOutputString = $testOutput -join "`n"

if ($testOutputString -match '(\d+) tests? completed') { $testsRun = [int]$matches[1] }
if ($testOutputString -match '(\d+) failed') { $testsFailed = [int]$matches[1] }

$testsPassed = $testsRun - $testsFailed

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
Write-Host "   • Tests Failed: $testsFailed"
Write-Host "   • Code Coverage: $coveragePercent"
Write-Host "   • Execution Time: ${executionTime}s"
Write-Host ""