# Java Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the Java environment setup and runs only the main Gilded Rose test

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "=== Java Gilded Rose Environment Verification ===" -ForegroundColor Cyan
Write-Host

# Check if we're in the correct directory
if (-not (Test-Path "build.gradle")) {
    Write-Host "❌ Error: build.gradle not found. Please run this script from the Java implementation directory." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found build.gradle" -ForegroundColor Green

# Check if Java is available
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "✅ Java found: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Java is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if gradlew exists
if (-not (Test-Path "./gradlew")) {
    Write-Host "❌ Error: gradlew not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Gradle wrapper found" -ForegroundColor Green

# Verify project structure
if (-not (Test-Path "src/main/java/com/gildedrose")) {
    Write-Host "❌ Error: Main source directory not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "src/test/java/com/gildedrose")) {
    Write-Host "❌ Error: Test source directory not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Project structure verified" -ForegroundColor Green

# Build the project (without running tests)
Write-Host
Write-Host "🔨 Building project..." -ForegroundColor Yellow
try {
    & ./gradlew assemble -q
    Write-Host "✅ Build successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Build failed" -ForegroundColor Red
    exit 1
}

# Run only the main Gilded Rose test (excluding secret tests)
Write-Host
Write-Host "🧪 Running Gilded Rose tests (excluding secret tests)..." -ForegroundColor Yellow
Write-Host

# Run only the GildedRoseTest class, excluding SecretTest classes
try {
    & ./gradlew test --tests "GildedRoseTest" -q
    Write-Host
    Write-Host "✅ Environment verification completed successfully!" -ForegroundColor Green
    Write-Host "✅ Main Gilded Rose test executed" -ForegroundColor Green
    Write-Host
    Write-Host "Note: Secret tests are excluded from this verification." -ForegroundColor Cyan
    Write-Host "To run all tests including secret tests, use: ./gradlew test" -ForegroundColor Cyan
} catch {
    Write-Host
    Write-Host "⚠️  Main Gilded Rose test failed (this may be expected for characterization testing)" -ForegroundColor Yellow
    Write-Host "✅ Environment setup is correct - test execution completed" -ForegroundColor Green
    Write-Host
    Write-Host "Note: A failing test may be intentional for characterization testing." -ForegroundColor Cyan
    Write-Host "The important thing is that the environment can compile and run tests." -ForegroundColor Cyan
}

Write-Host
Write-Host "🎉 Java environment verification complete!" -ForegroundColor Green