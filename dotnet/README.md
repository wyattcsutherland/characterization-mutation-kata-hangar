# .NET Code Smells Refactoring Kata

This is a C# conversion of the Java Code Smells Refactoring Kata, designed to teach developers how to identify, protect against, and refactor code smells using the classic "Gilded Rose" kata.

## 🎯 **Project Purpose**
This is part of a 3-session hands-on training series:
1. **Detect** - Identifying code smells
2. **Protect** - Building safety nets with characterization and mutation testing  
3. **Correct** - Safe refactoring techniques

## 🏗️ **Technical Stack**
- **Language**: C# (.NET 8.0)
- **Build Tool**: .NET CLI (dotnet)
- **Testing**: NUnit 3
- **Mutation Testing**: Stryker.NET (equivalent to PITest for Java)
- **Structure**: Standard .NET solution layout

## 🚀 **Getting Started**

### Prerequisites
- .NET 8.0 SDK or later
- Visual Studio 2022, VS Code, or JetBrains Rider

### Build and Run
```bash
# Navigate to the project directory
cd net-convert

# Restore dependencies
dotnet restore

# Build the solution
dotnet build

# Run tests
dotnet test

# Run mutation testing
dotnet stryker
```

## 📋 **Project Structure**

```
net-convert/
├── GildedRose.sln                    # Solution file
├── src/
│   ├── GildedRose/
│   │   ├── GildedRose.csproj         # Main project file
│   │   ├── GildedRose.cs             # Main business logic (intentionally messy)
│   │   └── Item.cs                   # Simple data class
│   └── GildedRose.Tests/
│       ├── GildedRose.Tests.csproj   # Test project file
│       ├── GildedRoseTests.cs        # Basic unit tests
│       ├── SecretTest1.cs            # Additional test scenarios
│       ├── SecretTest2.cs            # More test scenarios
│       └── SecretTest3.cs            # Extended test scenarios
├── stryker-config.json               # Mutation testing configuration
└── .editorconfig                     # Code style configuration
```

## 🦨 **Intentional Code Smells in GildedRose.cs**
The main class is deliberately written poorly to demonstrate multiple code smells:

- **Long Method** - The `Process()` method is overly complex (102+ lines)
- **Magic Numbers** - Constants like `FORTY_TWO = 42` and `FIFTY = FORTY_TWO + 7`
- **Dead Code** - Unused variables, unreachable branches, no-op operations
- **Bad Names** - Cryptic variable names like `ls`, `w`, `v`
- **Ticket Chatter** - Comments with developer conversations and TODO items
- **Primitive Obsession** - Using raw strings instead of enums for item types
- **Conditional Complexity** - Deeply nested if-else statements (6 levels deep)
- **Duplication** - Repeated quality adjustment logic
- **Swallowed Exceptions** - Empty catch blocks
- **Misleading Code** - Assignment in conditionals (`experimentalFlag = true`)

## 🎓 **Learning Objectives**
Students learn to:
1. **Spot** unhealthy code patterns using C# analyzers and linters
2. **Write characterization tests** using NUnit to lock in existing behavior
3. **Use mutation testing** with Stryker.NET to strengthen test coverage
4. **Apply safe refactoring techniques** using Visual Studio/Rider refactoring tools
5. **Transform messy legacy code** into clean, maintainable C# code

## 🔧 **C# Specific Features**
This .NET version includes:
- **C# Properties** - Converting Java fields to proper C# properties
- **String Interpolation** - Using `$""` syntax for string formatting
- **LINQ** - Potential for refactoring loops and collections
- **Nullable Reference Types** - Modern C# nullable annotations
- **NUnit Assertions** - Fluent assertion syntax with `Is.EqualTo()`
- **Stryker Mutation Testing** - .NET equivalent of PITest

## 📚 **Key Differences from Java Version**
- **NUnit** instead of JUnit 5
- **Stryker.NET** instead of PITest for mutation testing
- **C# naming conventions** (PascalCase for properties and methods)
- **Properties** instead of public fields
- **String interpolation** instead of concatenation
- **.NET project structure** instead of Maven/Gradle

This provides an excellent hands-on learning environment for .NET developers wanting to improve their refactoring skills and code quality awareness!