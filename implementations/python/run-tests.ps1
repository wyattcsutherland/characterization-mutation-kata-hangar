# Python Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the Python environment setup and runs only the main Gilded Rose test

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "=== Python Gilded Rose Environment Verification ===" -ForegroundColor Cyan
Write-Host

# Check if we're in the correct directory
if (-not (Test-Path "gilded_rose.py")) {
    Write-Host "❌ Error: gilded_rose.py not found. Please run this script from the Python implementation directory." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found gilded_rose.py" -ForegroundColor Green

# Check if Python is available
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Python is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check for virtual environment
if (-not (Test-Path ".venv")) {
    Write-Host "❌ Error: Virtual environment (.venv) not found" -ForegroundColor Red
    Write-Host "Please create a virtual environment with: python -m venv .venv" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Virtual environment found" -ForegroundColor Green

# Activate virtual environment
Write-Host "🔧 Activating virtual environment..." -ForegroundColor Yellow

# For PowerShell on Windows
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    & .\.venv\Scripts\Activate.ps1
} else {
    # For PowerShell on Linux/macOS
    & ./.venv/bin/Activate.ps1
}

# Check if pytest is installed
try {
    python -c "import pytest" 2>$null
    Write-Host "✅ pytest is available" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: pytest is not installed in the virtual environment" -ForegroundColor Red
    Write-Host "Please install requirements with: pip install -r requirements.txt" -ForegroundColor Yellow
    exit 1
}

# Verify project structure
if (-not (Test-Path "test_gilded_rose.py")) {
    Write-Host "❌ Error: Main test file (test_gilded_rose.py) not found" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Project structure verified" -ForegroundColor Green

# Run only the main Gilded Rose test (excluding secret tests)
Write-Host
Write-Host "🧪 Running Gilded Rose tests (excluding secret tests)..." -ForegroundColor Yellow
Write-Host

# Run only the main test file, excluding secret test files
try {
    & python -m pytest test_gilded_rose.py -v
    Write-Host
    Write-Host "✅ Environment verification completed successfully!" -ForegroundColor Green
    Write-Host "✅ Main Gilded Rose test executed" -ForegroundColor Green
    Write-Host
    Write-Host "Note: Secret tests are excluded from this verification." -ForegroundColor Cyan
    Write-Host "To run all tests including secret tests, use: python -m pytest" -ForegroundColor Cyan
} catch {
    Write-Host
    Write-Host "⚠️  Main Gilded Rose test failed (this may be expected for characterization testing)" -ForegroundColor Yellow
    Write-Host "✅ Environment setup is correct - test execution completed" -ForegroundColor Green
    Write-Host
    Write-Host "Note: A failing test may be intentional for characterization testing." -ForegroundColor Cyan
    Write-Host "The important thing is that the environment can run tests." -ForegroundColor Cyan
}

# Deactivate virtual environment (if function exists)
if (Get-Command deactivate -ErrorAction SilentlyContinue) {
    deactivate
}

Write-Host
Write-Host "🎉 Python environment verification complete!" -ForegroundColor Green