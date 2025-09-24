#!/bin/bash

# .NET Gilded Rose Environment Verification Script
# This script verifies the .NET environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

# Check if we're in the correct directory
if [ ! -f "stryker-config.json" ]; then
    echo "❌ Error: stryker-config.json not found. Please run this script from the .NET implementation directory."
    exit 1
fi

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

# Run only the main Gilded Rose test (excluding secret tests)
echo "🧪 Running Gilded Rose tests (excluding secret tests)..."

# Change to Tests directory and run only GildedRoseTest
cd Tests

# Run tests excluding any with "Secret" in the name
dotnet test --filter "FullyQualifiedName~GildedRoseTest&FullyQualifiedName!~Secret" --verbosity minimal --nologo