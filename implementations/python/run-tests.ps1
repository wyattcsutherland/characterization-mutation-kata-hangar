# Python Gilded Rose Environment Verification Script (PowerShell)
# This script verifies the Python environment setup and runs only the main Gilded Rose test

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
    Write-Host "Please create a virtual environment with: python3 -m venv .venv"
    exit 1
}

# Activate virtual environment
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    & .\.venv\Scripts\Activate.ps1
} else {
    # For PowerShell on Linux/macOS
    & ./.venv/bin/Activate.ps1
}

# Check if pytest is installed
try {
    python -c "import pytest" 2>$null
} catch {
    Write-Host "❌ Error: pytest is not installed in the virtual environment"
    Write-Host "Please install requirements with: pip install -r requirements.txt"
    exit 1
}

if (-not (Test-Path "test_gilded_rose.py")) {
    Write-Host "❌ Error: Main test file (test_gilded_rose.py) not found"
    exit 1
}

Write-Host "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Run only the main test file, excluding secret test files
& python -m pytest test_gilded_rose.py -v

# Deactivate virtual environment (if function exists)
if (Get-Command deactivate -ErrorAction SilentlyContinue) {
    deactivate
}