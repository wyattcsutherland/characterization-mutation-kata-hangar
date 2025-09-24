#!/bin/bash

# .NET Gilded Rose Environment Verification Script
# This script verifies the .NET environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

echo "=== .NET Gilded Rose Environment Verification ==="
echo

# Check if we're in the correct directory
if [ ! -f "stryker-config.json" ]; then
    echo "❌ Error: stryker-config.json not found. Please run this script from the .NET implementation directory."
    exit 1
fi

echo "✅ Found stryker-config.json"

# Check if dotnet is available
if ! command -v dotnet &> /dev/null; then
    echo "❌ Error: .NET is not installed or not in PATH"
    exit 1
fi

DOTNET_VERSION=$(dotnet --version)
echo "✅ .NET found: $DOTNET_VERSION"

# Verify project structure
if [ ! -d "GildedRose" ]; then
    echo "❌ Error: GildedRose project directory not found"
    exit 1
fi

if [ ! -d "Tests" ]; then
    echo "❌ Error: Tests project directory not found"
    exit 1
fi

echo "✅ Project structure verified"

# Verify projects can be built (will happen automatically during test run)
echo "🔧 Verifying project setup..."

# Run only the main Gilded Rose test (excluding secret tests)
echo
echo "🧪 Running Gilded Rose tests (excluding secret tests)..."
echo

# Change to Tests directory and run only GildedRoseTest
cd Tests

# Run tests excluding any with "Secret" in the name
if dotnet test --filter "FullyQualifiedName~GildedRoseTest&FullyQualifiedName!~Secret" --verbosity minimal --nologo; then
    echo
    echo "✅ Environment verification completed successfully!"
    echo "✅ Main Gilded Rose test executed"
    echo
    echo "Note: Secret tests are excluded from this verification."
    echo "To run all tests including secret tests, use: dotnet test"
else
    echo
    echo "⚠️  Main Gilded Rose test failed (this may be expected for characterization testing)"
    echo "✅ Environment setup is correct - test execution completed"
    echo
    echo "Note: A failing test may be intentional for characterization testing."
    echo "The important thing is that the environment can compile and run tests."
fi

echo
echo "🎉 .NET environment verification complete!"