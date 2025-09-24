#!/bin/bash

# Python Gilded Rose Environment Verification Script
# This script verifies the Python environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

if [ ! -f "gilded_rose.py" ]; then
    echo "❌ Error: gilded_rose.py not found. Please run this script from the Python implementation directory."
    exit 1
fi

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

source .venv/bin/activate

# Check if pytest is installed
if ! python -c "import pytest" 2>/dev/null; then
    echo "❌ Error: pytest is not installed in the virtual environment"
    echo "Please install requirements with: pip install -r requirements.txt"
    exit 1
fi

if [ ! -f "test_gilded_rose.py" ]; then
    echo "❌ Error: Main test file (test_gilded_rose.py) not found"
    exit 1
fi

echo "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Run only the main test file, excluding secret test files
pytest test_gilded_rose.py -v

# Deactivate virtual environment
deactivate
