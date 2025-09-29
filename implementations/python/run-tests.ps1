# Python Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the Python environment setup and runs only the main Gilded Rose test
# Usage: ./run-tests.ps1 [mutate]
#   mutate - Run mutation tests in addition to regular tests

param(
    [switch]$mutate
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path "gilded_rose.py")) {
    Write-Host "❌ Error: gilded_rose.py not found. Please run this script from the Python implementation directory."
    exit 1
}

# Check if Python is available
try {
    $pythonVersion = python3 --version 2>&1
    if (-not $pythonVersion) {
        $pythonVersion = python --version 2>&1
    }
    Write-Host "✅ Python found: $pythonVersion"
} catch {
    Write-Host "❌ Error: Python 3 is not installed or not in PATH"
    exit 1
}

# Check for virtual environment
if (-not (Test-Path ".venv")) {
    Write-Host "❌ Error: Virtual environment (.venv) not found"
    Write-Host "Creating virtual environment with: python3 -m venv .venv"
    python3 -m venv .venv
}

# Activate virtual environment
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    Write-Host "Activating virtual environment"
    & .\.venv\Scripts\Activate.ps1
} else {
    # For PowerShell on Linux/macOS
    Write-Host "Activating virtual environment (for PowerShell on Linux/macOS)"
    & ./.venv/bin/Activate.ps1
}

# Check if pytest is installed
$pytestCheck = python -c "import pytest" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: pytest is not installed in the virtual environment"
    Write-Host "Installing requirements with: pip install -r requirements.txt"
    pip install -r requirements.txt
}

if (-not (Test-Path "test_gilded_rose.py")) {
    Write-Host "❌ Error: Main test file (test_gilded_rose.py) not found"
    exit 1
}

Write-Host "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Record start time
$startTime = Get-Date

# Run only the main test file with coverage, excluding secret test files
$testOutput = & python -m pytest test_gilded_rose.py --cov=gilded_rose --cov-report=term-missing --tb=short -v 2>&1
$testExitCode = $LASTEXITCODE

# Record end time and calculate duration
$endTime = Get-Date
$executionTime = [math]::Round(($endTime - $startTime).TotalSeconds, 3)

# Parse test results from pytest output
$testsPassed = 0
$testsFailed = 0
$testsError = 0

$testOutputString = $testOutput -join "`n"

if ($testOutputString -match '(\d+) passed') { $testsPassed = [int]$matches[1] }
if ($testOutputString -match '(\d+) failed') { $testsFailed = [int]$matches[1] }
if ($testOutputString -match '(\d+) error') { $testsError = [int]$matches[1] }

$testsTotal = $testsPassed + $testsFailed + $testsError

# Parse coverage information
$coveragePercent = "N/A"
if ($testOutputString -match 'TOTAL.*?(\d+)%') {
    $coveragePercent = $matches[1] + "%"
}

# Display failed test details if any tests failed
if (($testsFailed -gt 0) -or ($testsError -gt 0)) {
    Write-Host "❌ Failed Test Details:"
    $failureLines = $testOutput | Where-Object { $_ -match "(FAILED|ERROR|AssertionError)" } | Select-Object -First 5
    foreach ($line in $failureLines) {
        Write-Host "   $line"
    }
    Write-Host ""
}

# Display test summary
Write-Host "📊 Test Results Summary:"
Write-Host "   • Tests Run: $testsTotal"
Write-Host "   • Tests Passed: $testsPassed"
Write-Host "   • Tests Failed: $($testsFailed + $testsError)"
Write-Host "   • Code Coverage: $coveragePercent"
Write-Host "   • Execution Time: ${executionTime}s"
Write-Host ""

# Run mutation tests if requested
if ($mutate) {
    Write-Host "🧬 Running mutation tests with mutmut..."
    
    # Record mutation test start time
    $mutationStartTime = Get-Date
    
    # Check if mutmut is installed
    try {
        python -c "import mutmut" 2>$null
    } catch {
        Write-Host "❌ Error: mutmut is not installed in the virtual environment"
        Write-Host "Please install mutmut with: pip install mutmut"
        exit 1
    }
    
    # Run mutmut mutation testing
    $mutationOutput = & python -m mutmut run --max-children 2 2>&1
    $mutationExitCode = $LASTEXITCODE
    
    # Record mutation test end time and calculate duration
    $mutationEndTime = Get-Date
    $mutationExecutionTime = [math]::Round(($mutationEndTime - $mutationStartTime).TotalSeconds, 3)
    
    # Parse mutation test results using mutmut results command for accurate counts
    $resultsOutput = & mutmut results --all True 2>$null
    
    $mutationsGenerated = 0
    $mutationsKilled = 0
    $mutationsSurvived = 0
    $mutationsTimeout = 0
    $mutationsSuspicious = 0
    $mutationsSkipped = 0
    
    if ($resultsOutput -and $resultsOutput.Trim()) {
        # Count each type of result from the mutmut results output
        $resultLines = $resultsOutput -split "`n" | Where-Object { $_.Trim() }
        $mutationsGenerated = $resultLines.Count
        $mutationsKilled = ($resultLines | Where-Object { $_ -match ': killed' }).Count
        $mutationsSurvived = ($resultLines | Where-Object { $_ -match ': survived' }).Count
        $mutationsSkipped = ($resultLines | Where-Object { $_ -match ': no tests' }).Count
        $mutationsTimeout = ($resultLines | Where-Object { $_ -match ': timeout' }).Count
        $mutationsSuspicious = ($resultLines | Where-Object { $_ -match ': suspicious' }).Count
    } else {
        # Fallback to parsing console output if mutmut results fails
        $mutationOutputString = $mutationOutput -join "`n"
        
        # Extract the final summary line with pattern like "160/160  🎉 79 🫥 7  ⏰ 0  🤔 0  🙁 74  🔇 0"
        if ($mutationOutputString -match '(\d+)/(\d+)\s+🎉\s*(\d+)\s+🫥\s*(\d+)\s+⏰\s*(\d+)\s+🤔\s*(\d+)\s+🙁\s*(\d+)') {
            $mutationsGenerated = [int]$matches[2]
            $mutationsKilled = [int]$matches[3]
            $mutationsSkipped = [int]$matches[4]
            $mutationsTimeout = [int]$matches[5]
            $mutationsSuspicious = [int]$matches[6]
            $mutationsSurvived = [int]$matches[7]
        }
    }
    
    # Calculate mutation score if we have data
    $mutationScore = "N/A"
    if ($mutationsGenerated -gt 0) {
        $mutationScore = [math]::Round(($mutationsKilled * 100) / $mutationsGenerated, 0).ToString() + "%"
    }
    
    # Calculate coverage from mutations that were tested (excluding skipped)
    $mutationsTested = $mutationsKilled + $mutationsSurvived + $mutationsTimeout + $mutationsSuspicious
    $mutationCoverage = "N/A"
    if ($mutationsTested -gt 0) {
        $mutationCoverage = [math]::Round(($mutationsTested * 100) / $mutationsGenerated, 0).ToString() + "%"
    }
    
    # Display mutation test results
    Write-Host "🧬 Mutation Test Results Summary:"
    Write-Host "   • Mutations Generated: $mutationsGenerated"
    Write-Host "   • Mutations Killed: $mutationsKilled"
    Write-Host "   • Mutations Survived: $mutationsSurvived"
    
    # Only show additional stats if they have meaningful values
    $showExtraStats = ($mutationsTimeout -gt 0) -or ($mutationsSuspicious -gt 0) -or ($mutationsSkipped -gt 0)
    
    if ($showExtraStats) {
        if ($mutationsTimeout -gt 0) {
            Write-Host "   • Mutations Timeout: $mutationsTimeout"
        }
        if ($mutationsSuspicious -gt 0) {
            Write-Host "   • Mutations Suspicious: $mutationsSuspicious"
        }
        if ($mutationsSkipped -gt 0) {
            Write-Host "   • Mutations Skipped: $mutationsSkipped"
        }
    }
    Write-Host "   • Mutation Coverage: $mutationCoverage"
    Write-Host "   • Mutation Score: $mutationScore"
    Write-Host "   • Mutation Test Time: ${mutationExecutionTime}s"
    Write-Host ""
    
    # Show how to browse results
    Write-Host "📋 To view detailed mutation results, run: mutmut show"
    Write-Host "📋 To view HTML report, run: mutmut html && open html/index.html"
    Write-Host ""
    
    # Display survived mutations warning if any
    if ($mutationsSurvived -gt 0) {
        Write-Host "⚠️  Some mutations survived - consider improving test quality"
        Write-Host "   Run 'mutmut show <id>' to see specific survived mutations"
        Write-Host ""
    }
}

# Deactivate virtual environment (if function exists)
if (Get-Command deactivate -ErrorAction SilentlyContinue) {
    deactivate
}