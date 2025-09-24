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
    # Run tests excluding any with "Secret" in the name
    & dotnet test --filter "FullyQualifiedName~GildedRoseTest&FullyQualifiedName!~Secret" --verbosity minimal --nologo
} finally {
    Pop-Location
}