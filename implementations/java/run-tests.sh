#!/bin/bash

# Java Gilded Rose Environment Verification Script
# This script verifies the Java environment setup and runs only the main Gilded Rose test

set -e  # Exit on any error

echo "=== Java Gilded Rose Environment Verification ==="
echo

# Check if we're in the correct directory
if [ ! -f "build.gradle" ]; then
    echo "❌ Error: build.gradle not found. Please run this script from the Java implementation directory."
    exit 1
fi

echo "✅ Found build.gradle"

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java is not installed or not in PATH"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo "✅ Java found: $JAVA_VERSION"

# Check if gradlew is executable
if [ ! -x "./gradlew" ]; then
    echo "🔧 Making gradlew executable..."
    chmod +x ./gradlew
fi

echo "✅ Gradle wrapper is executable"

# Verify project structure
if [ ! -d "src/main/java/com/gildedrose" ]; then
    echo "❌ Error: Main source directory not found"
    exit 1
fi

if [ ! -d "src/test/java/com/gildedrose" ]; then
    echo "❌ Error: Test source directory not found"
    exit 1
fi

echo "✅ Project structure verified"

# Build the project (without running tests)
echo
echo "🔨 Building project..."
if ! ./gradlew assemble -q; then
    echo "❌ Error: Build failed"
    exit 1
fi

echo "✅ Build successful"

# Run only the main Gilded Rose test (excluding secret tests)
echo
echo "🧪 Running Gilded Rose tests (excluding secret tests)..."
echo

# Run only the GildedRoseTest class, excluding SecretTest classes
if ./gradlew test --tests "GildedRoseTest" -q; then
    echo
    echo "✅ Environment verification completed successfully!"
    echo "✅ Main Gilded Rose test executed"
    echo
    echo "Note: Secret tests are excluded from this verification."
    echo "To run all tests including secret tests, use: ./gradlew test"
else
    echo
    echo "⚠️  Main Gilded Rose test failed (this may be expected for characterization testing)"
    echo "✅ Environment setup is correct - test execution completed"
    echo
    echo "Note: A failing test may be intentional for characterization testing."
    echo "The important thing is that the environment can compile and run tests."
fi

echo
echo "🎉 Java environment verification complete!"