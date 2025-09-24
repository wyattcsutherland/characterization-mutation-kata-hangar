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

& ./gradlew test --tests "GildedRoseTest" --info