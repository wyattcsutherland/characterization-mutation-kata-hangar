# .NET Gilded Rose Test Script (PowerShell)
param([switch]$mutate)

$ErrorActionPreference = "Stop"

# Parse arguments
$runMutationTests = $false
if ($mutate -or ($args -contains "mutate")) {
    $runMutationTests = $true
}

# Check dotnet
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET found: $dotnetVersion"
} catch {
    Write-Host "❌ Error: .NET SDK not found"
    exit 1
}

# Verify project structure
if (!(Test-Path "GildedRose/GildedRose.csproj")) {
    Write-Host "❌ Error: GildedRose.csproj not found"
    exit 1
}

if (!(Test-Path "Tests/Tests.csproj")) {
    Write-Host "❌ Error: Tests.csproj not found"
    exit 1
}

# Run tests
Write-Host "🧪 Running Gilded Rose tests..."
Set-Location Tests
$startTime = Get-Date
$testOutput = & dotnet test --collect:"XPlat Code Coverage" --verbosity normal --nologo 2>&1
$endTime = Get-Date
$executionTime = [math]::Round(($endTime - $startTime).TotalSeconds, 3)

# Parse results
$testOutputString = $testOutput -join "`n"
$testsTotal = if ($testOutputString -match "Total tests:\s*(\d+)") { [int]$matches[1] } else { 1 }
$testsPassed = if ($testOutputString -match "Passed:\s*(\d+)") { [int]$matches[1] } else { 0 }
$testsFailed = if ($testOutputString -match "Failed:\s*(\d+)") { [int]$matches[1] } else { 0 }

# Calculate missing values
if ($testsTotal -eq 0 -and ($testsPassed -gt 0 -or $testsFailed -gt 0)) {
    $testsTotal = $testsPassed + $testsFailed
}
if ($testsPassed -eq 0 -and $testsTotal -gt 0) {
    $testsPassed = $testsTotal - $testsFailed
}

# Coverage
$coveragePercent = "N/A"
$coverageFile = Get-ChildItem TestResults -Filter "coverage.cobertura.xml" -Recurse -EA 0 | Select-Object -First 1
if ($coverageFile) {
    $content = Get-Content $coverageFile.FullName -Raw
    if ($content -match 'line-rate="([0-9.]*)"') {
        $coveragePercent = [math]::Round([double]$matches[1] * 100).ToString() + "%"
    }
}

Write-Host "📊 Test Results Summary:"
Write-Host "   • Tests Run: $testsTotal"
Write-Host "   • Tests Passed: $testsPassed"
Write-Host "   • Tests Failed: $testsFailed"
Write-Host "   • Code Coverage: $coveragePercent"
Write-Host "   • Execution Time: $($executionTime)s"
Write-Host ""

# Go back to root directory for mutation testing
Set-Location ..

# Mutation testing
if ($runMutationTests) {
    Write-Host "🧬 Running mutation tests with Stryker..."
    $mutationStartTime = Get-Date
    & dotnet stryker --config-file stryker-config.json
    $mutationEndTime = Get-Date
    $mutationExecutionTime = [math]::Round(($mutationEndTime - $mutationStartTime).TotalSeconds, 3)
    
    # Find JSON report
    $latestJsonReport = Get-ChildItem StrykerOutput -Recurse -Filter "mutation-report.json" -EA 0 | Sort-Object LastWriteTime | Select-Object -Last 1
    
    $mutationsKilled = 0
    $mutationsSurvived = 0
    $mutationsTimeout = 0
    $mutationsIgnored = 0
    $mutationsNoCoverage = 0
    $mutationScore = 0
    
    if ($latestJsonReport) {
        Write-Host "📊 Parsing results from JSON report: $($latestJsonReport.FullName)"
        try {
            $jsonContent = Get-Content $latestJsonReport.FullName -Raw | ConvertFrom-Json
            foreach ($file in $jsonContent.files.PSObject.Properties) {
                foreach ($mutant in $file.Value.mutants) {
                    switch ($mutant.status) {
                        "Killed" { $mutationsKilled++ }
                        "Survived" { $mutationsSurvived++ }
                        "Timeout" { $mutationsTimeout++ }
                        "Ignored" { $mutationsIgnored++ }
                        "NoCoverage" { $mutationsNoCoverage++ }
                    }
                }
            }
        } catch {
            Write-Host "⚠️  JSON parsing failed"
            $mutationsKilled = 0
            $mutationsSurvived = 0
            $mutationsTimeout = 0
            $mutationScore = 0
        }
    } else {
        Write-Host "⚠️  JSON report not found. Unable to parse mutation results."
        $mutationsKilled = 0
        $mutationsSurvived = 0
        $mutationsTimeout = 0
        $mutationScore = 0
    }
    
    $mutationsTested = $mutationsKilled + $mutationsSurvived + $mutationsTimeout
    if ($mutationScore -eq 0 -and $mutationsTested -gt 0) {
        $mutationScore = [math]::Round(($mutationsKilled / $mutationsTested) * 100, 2)
    }
    
    if ($mutationScore -gt 0) {
        $mutationScoreDisplay = $mutationScore.ToString() + "%"
    } else {
        $mutationScoreDisplay = "N/A"
    }
    
    Write-Host "🧬 Mutation Test Results Summary:"
    Write-Host "   • Mutations Tested: $mutationsTested"
    Write-Host "   • Mutations Killed: $mutationsKilled"
    Write-Host "   • Mutations Survived: $mutationsSurvived"
    Write-Host "   • Mutations Timeout: $mutationsTimeout"
    if ($mutationsIgnored -gt 0 -or $mutationsNoCoverage -gt 0) {
        Write-Host "   • Mutations Ignored: $mutationsIgnored"
        Write-Host "   • Mutations No Coverage: $mutationsNoCoverage"
    }
    Write-Host "   • Mutation Score: $mutationScoreDisplay"
    Write-Host "   • Mutation Test Time: $($mutationExecutionTime)s"
    Write-Host ""
    
    $latestReport = Get-ChildItem StrykerOutput -Recurse -Filter "mutation-report.html" -EA 0 | Sort-Object LastWriteTime | Select-Object -First 1
    if ($latestReport) {
        Write-Host "📋 Mutation test report available at: $($latestReport.FullName)"
        Write-Host ""
    }
}

if ($testsFailed -gt 0) {
    Write-Host "❌ Some tests failed"
    exit 1
} else {
    Write-Host "✅ All tests passed successfully!"
    exit 0
}
