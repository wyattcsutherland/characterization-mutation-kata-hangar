# GildedRose .NET Implementation

This is a C# .NET Core implementation of the GildedRose kata, equivalent to the Java version.

## Prerequisites

- .NET 8.0 SDK or later

## Building and Testing

### Build the project:
```bash
dotnet build GildedRose/GildedRose.csproj
```

### Run tests:
```bash
dotnet test Tests/Tests.csproj
```

### Build and test everything:
```bash
dotnet build
dotnet test
```

## Mutation Testing with Stryker.NET

This project is configured to use Stryker.NET for mutation testing.

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

### Run mutation testing:
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
  - `GildedRoseTest.cs` - Unit tests
- `stryker-config.json` - Stryker mutation testing configuration
- `.config/dotnet-tools.json` - Local tool manifest for Stryker

## Notes

This implementation maintains the same behavior and structure as the Java version, including:
- All the complex business logic with nested conditions
- The same method names (adapted to C# naming conventions)
- The same intentional bugs and TODO comments
- The same test that currently fails (expecting "0, 0" but getting "4, 9")

The failing test is intentional and part of the kata's characterization testing approach.