#!/bin/bash

# Python Gilded Rose Environment Verification Script
# This script verifies the Python environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

echo "=== Python Gilded Rose Environment Verification ==="
echo

# Check if we're in the correct directory
if [ ! -f "gilded_rose.py" ]; then
    echo "❌ Error: gilded_rose.py not found. Please run this script from the Python implementation directory."
    exit 1
fi

echo "✅ Found gilded_rose.py"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed or not in PATH"
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
echo "✅ Python found: $PYTHON_VERSION"

# Check for virtual environment
if [ ! -d ".venv" ]; then
    echo "❌ Error: Virtual environment (.venv) not found"
    echo "Please create a virtual environment with: python3 -m venv .venv"
    exit 1
fi

echo "✅ Virtual environment found"

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source .venv/bin/activate

# Check if pytest is installed
if ! python -c "import pytest" 2>/dev/null; then
    echo "❌ Error: pytest is not installed in the virtual environment"
    echo "Please install requirements with: pip install -r requirements.txt"
    exit 1
fi

echo "✅ pytest is available"

# Verify project structure
if [ ! -f "test_gilded_rose.py" ]; then
    echo "❌ Error: Main test file (test_gilded_rose.py) not found"
    exit 1
fi

echo "✅ Project structure verified"

# Run only the main Gilded Rose test (excluding secret tests)
echo
echo "🧪 Running Gilded Rose tests (excluding secret tests)..."
echo

# Run only the main test file, excluding secret test files
if python -m pytest test_gilded_rose.py -v; then
    echo
    echo "✅ Environment verification completed successfully!"
    echo "✅ Main Gilded Rose test executed"
    echo
    echo "Note: Secret tests are excluded from this verification."
    echo "To run all tests including secret tests, use: python -m pytest"
else
    echo
    echo "⚠️  Main Gilded Rose test failed (this may be expected for characterization testing)"
    echo "✅ Environment setup is correct - test execution completed"
    echo
    echo "Note: A failing test may be intentional for characterization testing."
    echo "The important thing is that the environment can run tests."
fi

# Deactivate virtual environment
deactivate

echo
echo "🎉 Python environment verification complete!"