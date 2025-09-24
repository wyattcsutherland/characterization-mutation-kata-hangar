# .NET Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the .NET environment setup and runs only the main Gilded Rose test

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "=== .NET Gilded Rose Environment Verification ===" -ForegroundColor Cyan
Write-Host

# Check if we're in the correct directory
if (-not (Test-Path "stryker-config.json")) {
    Write-Host "❌ Error: stryker-config.json not found. Please run this script from the .NET implementation directory." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found stryker-config.json" -ForegroundColor Green

# Check if dotnet is available
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET found: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: .NET is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Verify project structure
if (-not (Test-Path "GildedRose")) {
    Write-Host "❌ Error: GildedRose project directory not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "Tests")) {
    Write-Host "❌ Error: Tests project directory not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Project structure verified" -ForegroundColor Green

# Verify projects can be built (will happen automatically during test run)
Write-Host
Write-Host "🔧 Verifying project setup..." -ForegroundColor Yellow

# Run only the main Gilded Rose test (excluding secret tests)
Write-Host
Write-Host "🧪 Running Gilded Rose tests (excluding secret tests)..." -ForegroundColor Yellow
Write-Host

# Change to Tests directory and run only GildedRoseTest
Push-Location Tests

try {
    # Run tests excluding any with "Secret" in the name
    & dotnet test --filter "FullyQualifiedName~GildedRoseTest&FullyQualifiedName!~Secret" --verbosity minimal --nologo
    Write-Host
    Write-Host "✅ Environment verification completed successfully!" -ForegroundColor Green
    Write-Host "✅ Main Gilded Rose test executed" -ForegroundColor Green
    Write-Host
    Write-Host "Note: Secret tests are excluded from this verification." -ForegroundColor Cyan
    Write-Host "To run all tests including secret tests, use: dotnet test" -ForegroundColor Cyan
} catch {
    Write-Host
    Write-Host "⚠️  Main Gilded Rose test failed (this may be expected for characterization testing)" -ForegroundColor Yellow
    Write-Host "✅ Environment setup is correct - test execution completed" -ForegroundColor Green
    Write-Host
    Write-Host "Note: A failing test may be intentional for characterization testing." -ForegroundColor Cyan
    Write-Host "The important thing is that the environment can compile and run tests." -ForegroundColor Cyan
} finally {
    Pop-Location
}

Write-Host
Write-Host "🎉 .NET environment verification complete!" -ForegroundColor Green