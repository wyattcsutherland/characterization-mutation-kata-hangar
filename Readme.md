# Code Smells Refactoring Kata

This a Code Smells Refactoring Kata, designed to teach developers how to identify, protect against, and refactor code smells using the classic "Gilded Rose" kata.

## 🎯 **Project Purpose**
This is part of a 3-session hands-on training series:
1. **Detect** - Identifying code smells
2. **Protect** - Building safety nets with characterization and mutation testing  
3. **Correct** - Safe refactoring techniques

## 🏗️ **Technical Stack**
Please see the language specific folders for tech stack and set up instructions.

- **[Java](/java/)**
- **[.NET](/dotnet/README.md)**

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

This provides an excellent hands-on learning environment for developers wanting to improve their refactoring skills and code quality awareness!