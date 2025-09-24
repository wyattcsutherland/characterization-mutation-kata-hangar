# GildedRose .NET Implementation

This is a C# .NET Core implementation of the GildedRose kata, equivalent to the Java version.

## Prerequisites

- .NET 8.0 SDK or later

## Quick Start

### Verify environment and run basic tests:
```bash
# Linux/macOS/WSL
./run-tests.sh

# Windows PowerShell
./run-tests.ps1
```

### Run tests with mutation testing:
```bash
# Linux/macOS/WSL
./run-tests.sh mutate

# Windows PowerShell
./run-tests.ps1 mutate
# or
./run-tests.ps1 -mutate
```

These scripts will:
- ✅ Verify .NET SDK is installed
- 🔨 Build the projects
- 🧪 Run the main Gilded Rose test (excluding secret characterization tests)
- 📊 Display detailed test results and code coverage
- 🧬 Run mutation tests with Stryker.NET (when `mutate` parameter is provided)
- 📋 Generate comprehensive mutation test reports

## Building and Testing

### Build the projects:
```bash
dotnet build GildedRose/GildedRose.csproj
dotnet build Tests/Tests.csproj
```

### Run all tests (including secret tests):
```bash
cd Tests && dotnet test
```

### Run only main tests (excluding secret tests):
```bash
cd Tests && dotnet test --filter "FullyQualifiedName~GildedRoseTest&FullyQualifiedName!~Secret"
```

### Run tests with verbose output:
```bash
cd Tests && dotnet test --verbosity detailed
```

## Mutation Testing with Stryker.NET

This project is configured to use Stryker.NET for mutation testing.

### Run mutation testing using the test scripts (Recommended):
```bash
# Linux/macOS/WSL
./run-tests.sh mutate

# Windows PowerShell
./run-tests.ps1 mutate
```

This will run both regular tests and mutation tests, providing comprehensive results including:
- Test execution summary
- Code coverage metrics
- Mutation test statistics (mutations tested, killed, survived, timeout)
- Mutation score and coverage
- Links to detailed HTML reports

### Setup Stryker.NET

Stryker.NET is already configured as a local tool in this project. To set it up:

1. **Restore local tools** (if not already done):
   ```bash
   dotnet tool restore
   ```

2. **Verify Stryker installation**:
   ```bash
   dotnet tool list
   ```
   You should see `dotnet-stryker` listed.

### Alternative: Install Stryker globally
If you prefer to install Stryker globally on your system:
```bash
dotnet tool install -g dotnet-stryker
```

### Run mutation testing directly with Stryker:
```bash
dotnet stryker
```

### Run with specific configuration:
```bash
dotnet stryker --config-file stryker-config.json
```

### Common Stryker options:
```bash
# Run with verbose output
dotnet stryker --verbosity debug

# Run with custom thresholds
dotnet stryker --threshold-high 90 --threshold-low 70 --break-at 50

# Run only on specific files
dotnet stryker --mutate "**/GildedRose.cs"

# Run with fewer concurrent processes (useful on limited resources)
dotnet stryker --concurrency 2
```

The mutation test results will be available in the `StrykerOutput` directory as HTML reports.

## Project Structure

- `GildedRose/` - Main class library containing the business logic
  - `Item.cs` - Item class with Name, SellIn, and Quality properties
  - `GildedRose.cs` - Main business logic for processing items
- `Tests/` - Test project using xUnit
  - `GildedRoseTest.cs` - Main unit test
  - `SecretTest1.cs.bak` - Additional characterization tests (18 tests total)
  - `SecretTest2.cs.bak` - Additional characterization tests  
  - `SecretTest3.cs.bak` - Additional characterization tests
- `stryker-config.json` - Stryker mutation testing configuration
- `.config/dotnet-tools.json` - Local tool manifest for Stryker
- `run-tests.sh` / `run-tests.ps1` - Environment verification and test execution scripts with mutation testing support

## Test Script Features

The `run-tests.sh` and `run-tests.ps1` scripts provide:

### Standard Test Run:
- ✅ Environment verification (.NET SDK availability)
- 🔨 Project build verification
- 🧪 Test execution with detailed output
- 📊 Comprehensive results summary (tests run, passed, failed, coverage, execution time)
- ❌ Detailed failure analysis with test method and assertion details

### Mutation Testing Mode (with `mutate` parameter):
- 🧬 Stryker.NET mutation testing execution
- 📈 Mutation statistics (generated, killed, survived, timeout mutations)
- 📊 Mutation score and line coverage metrics
- 📋 HTML report generation with links
- ⚠️ Quality warnings when mutations survive
- ⏱️ Separate timing for regular tests and mutation tests

### Usage Examples:
```bash
# Basic test run
./run-tests.sh

# Full test run with mutation testing
./run-tests.sh mutate

# PowerShell equivalents
./run-tests.ps1
./run-tests.ps1 mutate
./run-tests.ps1 -mutate
```

## Test Categories

- **Main Test**: `GildedRoseTest` - The primary failing test for characterization
- **Secret Tests**: `SecretTest1-3` - Comprehensive characterization test suite with 18 tests

## Notes

This implementation maintains the same behavior and structure as the Java version, including:
- All the complex business logic with nested conditions
- The same method names (adapted to C# naming conventions)
- The same intentional bugs and TODO comments
- The same test that currently fails (expecting "0, 0" but getting "4, 9")

The failing test is intentional and part of the kata's characterization testing approach.