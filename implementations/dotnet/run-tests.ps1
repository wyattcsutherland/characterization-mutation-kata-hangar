# .NET Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the .NET environment setup and runs only the main Gilded Rose test
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
if (-not (Test-Path "stryker-config.json")) {
    Write-Host "❌ Error: stryker-config.json not found. Please run this script from the .NET implementation directory."
    exit 1
}

# Check if dotnet is available
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET found: $dotnetVersion"
} catch {
    Write-Host "❌ Error: .NET is not installed or not in PATH"
    exit 1
}

# Verify project structure
if (-not (Test-Path "GildedRose")) {
    Write-Host "❌ Error: GildedRose project directory not found"
    exit 1
}

if (-not (Test-Path "Tests")) {
    Write-Host "❌ Error: Tests project directory not found"
    exit 1
}

# Run only the main Gilded Rose test (excluding secret tests)
Write-Host "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Change to Tests directory and run only GildedRoseTest
Push-Location Tests

try {
    # Record start time
    $startTime = Get-Date
    
    # Run tests excluding any with "Secret" in the name, capture output
    $testOutput = & dotnet test --filter "FullyQualifiedName~GildedRoseTest&FullyQualifiedName!~Secret" --collect:"XPlat Code Coverage" --verbosity normal --nologo 2>&1
    $testExitCode = $LASTEXITCODE
    
    # Record end time and calculate duration
    $endTime = Get-Date
    $executionTime = [math]::Round(($endTime - $startTime).TotalSeconds, 3)
    
    # Parse test results from output
    $testsRun = 1
    $testsFailed = 0
    $testsTotal = 1
    $testOutputString = $testOutput -join "`n"
    
    if ($testOutputString -match 'Passed: (\d+)') { $testsRun = [int]$matches[1] }
    elseif ($testOutputString -match '(\d+) passed') { $testsRun = [int]$matches[1] }
    
    if ($testOutputString -match 'Failed: (\d+)') { $testsFailed = [int]$matches[1] }
    elseif ($testOutputString -match '(\d+) failed') { $testsFailed = [int]$matches[1] }
    
    if ($testOutputString -match 'Total: (\d+)') { $testsTotal = [int]$matches[1] }
    else { $testsTotal = $testsRun }
    
    $testsRun = $testsTotal
    $testsPassed = $testsRun - $testsFailed
    
    # Parse coverage information
    $coveragePercent = "N/A"
    $coverageFile = Get-ChildItem -Path "TestResults" -Filter "coverage.cobertura.xml" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($coverageFile) {
        $xmlContent = Get-Content $coverageFile.FullName -Raw
        if ($xmlContent -match 'line-rate="([0-9.]*)"') {
            $lineRate = [double]$matches[1]
            $coveragePercent = [math]::Round($lineRate * 100, 0).ToString() + "%"
        }
    }
    
    # Display failed test details if any tests failed
    if ($testsFailed -gt 0) {
        Write-Host "❌ Failed Test Details:"
        $failureLines = $testOutput | Where-Object { $_ -match "(FAIL|Failed|Error)" } | Select-Object -First 5
        foreach ($line in $failureLines) {
            Write-Host "   $line"
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
    
} finally {
    Pop-Location
}

# Run mutation tests if requested
if ($runMutationTests) {
    Write-Host "🧬 Running mutation tests with Stryker..."
    
    # Record mutation test start time
    $mutationStartTime = Get-Date
    
    # Run Stryker mutation testing
    $mutationOutput = & dotnet stryker --config-file stryker-config.json 2>&1
    $mutationExitCode = $LASTEXITCODE
    
    # Record mutation test end time and calculate duration
    $mutationEndTime = Get-Date
    $mutationExecutionTime = [math]::Round(($mutationEndTime - $mutationStartTime).TotalSeconds, 3)
    
    # Parse mutation test results
    $mutationOutputString = $mutationOutput -join "`n"
    $mutationsTested = 0
    $mutationsKilled = 0
    $mutationsSurvived = 0
    $mutationsTimeout = 0
    $mutationScore = "N/A"
    
    if ($mutationOutputString -match '(\d+) mutations tested') { $mutationsTested = [int]$matches[1] }
    elseif ($mutationOutputString -match '(\d+) mutants tested') { $mutationsTested = [int]$matches[1] }
    
    if ($mutationOutputString -match '(\d+) killed') { $mutationsKilled = [int]$matches[1] }
    if ($mutationOutputString -match '(\d+) survived') { $mutationsSurvived = [int]$matches[1] }
    if ($mutationOutputString -match '(\d+) timeout') { $mutationsTimeout = [int]$matches[1] }
    
    if ($mutationOutputString -match 'Mutation score: ([0-9.]+%)') { $mutationScore = $matches[1] }
    elseif ($mutationOutputString -match '([0-9.]+%)') { $mutationScore = $matches[1] }
    
    # Display mutation test results
    Write-Host "🧬 Mutation Test Results Summary:"
    Write-Host "   • Mutations Tested: $mutationsTested"
    Write-Host "   • Mutations Killed: $mutationsKilled"
    Write-Host "   • Mutations Survived: $mutationsSurvived"
    Write-Host "   • Mutations Timeout: $mutationsTimeout"
    Write-Host "   • Mutation Score: $mutationScore"
    Write-Host "   • Mutation Test Time: ${mutationExecutionTime}s"
    Write-Host ""
    
    # Show mutation test report location
    if (Test-Path "StrykerOutput") {
        $latestReport = Get-ChildItem -Path "StrykerOutput" -Filter "mutation-report.html" -Recurse | Select-Object -First 1
        if ($latestReport) {
            Write-Host "📋 Mutation test report available at: $($latestReport.FullName)"
            Write-Host ""
        }
    }
    
    # Display survived mutations warning if any
    if ($mutationsSurvived -gt 0) {
        Write-Host "⚠️  Some mutations survived - consider improving test quality"
        Write-Host "   Review the mutation test report for details on uncaught mutations"
        Write-Host ""
    }
}