# GildedRose Java Implementation

This is the original Java implementation of the GildedRose kata using Gradle and JUnit 5.

## Prerequisites

- Java 8 or later
- Gradle (or use the included Gradle wrapper)

## Quick Start

### Verify environment and run basic tests:
```bash
# Linux/macOS/WSL
./run-tests.sh

# Windows PowerShell
./run-tests.ps1
```

These scripts will:
- ✅ Verify Java and Gradle are installed
- 🔨 Build the project
- 🧪 Run the main Gilded Rose test (excluding secret characterization tests)

## Building and Testing

### Build the project:
```bash
./gradlew build
```

### Run all tests (including secret tests):
```bash
./gradlew test
```

### Run only main tests (excluding secret tests):
```bash
./gradlew test --tests "GildedRoseTest"
```

### Run tests with verbose output:
```bash
./gradlew test --info
```

## Mutation Testing with PIT

This project is configured to use PIT (Pitest) for mutation testing.

### Run mutation testing:
```bash
./gradlew pitest
```

### Generate HTML report:
The mutation test results will be available in `build/reports/pitest/` as HTML reports.

### Common PIT options:
```bash
# Run with verbose output
./gradlew pitest --info

# Run with custom target classes
./gradlew pitest -DtargetClasses=com.gildedrose.*

# Run with specific test classes
./gradlew pitest -DtargetTests=com.gildedrose.GildedRoseTest
```

## Project Structure

- `src/main/java/com/gildedrose/` - Main source code
  - `Item.java` - Item class with name, sellIn, and quality properties
  - `GildedRose.java` - Main business logic for processing items
- `src/test/java/com/gildedrose/` - Test classes
  - `GildedRoseTest.java` - Main unit test
  - `SecretTest1.java` - Additional characterization tests (18 tests total)
  - `SecretTest2.java` - Additional characterization tests
  - `SecretTest3.java` - Additional characterization tests
- `build.gradle` - Gradle build configuration with PIT mutation testing
- `run-tests.sh` / `run-tests.ps1` - Environment verification scripts

## Test Categories

- **Main Test**: `GildedRoseTest` - The primary failing test for characterization
- **Secret Tests**: `SecretTest1-3` - Comprehensive characterization test suite with 18 tests

## Notes

This implementation includes:
- Complex business logic with nested conditions
- Intentional bugs and TODO comments for the kata experience
- A failing main test (expecting "0, 0" but getting "4, 9")
- Comprehensive secret test suite for mutation testing

The failing test is intentional and part of the kata's characterization testing approach.