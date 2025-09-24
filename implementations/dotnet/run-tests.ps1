# .NET Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the .NET environment setup and runs only the main Gilded Rose test

$ErrorActionPreference = "Stop"

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