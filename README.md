# Code Smells → Characterization & Mutation Testing → Refactoring

This 3-part hands-on series takes you on a journey from **Detecting problems in code** to **Protecting behavior with safety nets** and finally to **Correcting design and structure with safe refactoring** so that working in your code becomes easier, safer, and joyful to maintain. Each session builds on the last, giving you confidence to work with legacy code fearlessly and effectively.

## 👃 Session #1: Code Smells (Detect)
- **Theme:** Why does some code just feel harder to work with?  
- **Focus:** Spot unhealthy patterns that make code risky or confusing.  
- **Outcomes:** Sharpen detection, recognize common smells (long methods, clutter, duplication, bad names), and make code easier, safer, and more joyful to maintain.  
- **You’ll leave with:** A sharper eye for hidden problems and a common vocabulary to talk about them.  

## 🛡️ Session #2: Characterization & Mutation Testing (Protect)
- **Theme:** How do we change code with confidence?  
- **Focus:** Build safety nets with characterization tests and strengthen them with mutation testing.  
- **Outcomes:** Lock in current behavior, shorten feedback loops, and trust your tests to catch surprises.  
- **You’ll leave with:** Confidence that your tests can guard against regressions and highlight blind spots.  

## ✅ Session #3: Refactoring (Correct)
- **Theme:** Now that we can spot problems and protect behavior, how do we safely improve code?  
- **Focus:** Make disciplined, small, safe changes without altering behavior.  
- **Outcomes:** Apply common refactorings, such as: remove clutter, extract method, rename, replace magic numbers, and more.  
- **You’ll leave with:** Hands-on experience turning messy code into clearer, more maintainable code.  

## Detect → Protect → Correct

By the end, you’ll have the tools and confidence to transform messy legacy code into clean, maintainable, and joyful code.

## 📁 Implementations

This repository contains multiple implementations of the Gilded Rose kata to practice the concepts across different technologies:

| Language | Location | Description |
|----------|----------|-------------|
| **C# / .NET** | [`implementations/dotnet/`](implementations/dotnet/) | .NET implementation with xUnit tests and Stryker mutation testing |
| **Java** | [`implementations/java/`](implementations/java/) | Java implementation with Gradle, JUnit tests, and PITest mutation testing |
| **Python** | [`implementations/python/`](implementations/python/) | Python implementation with pytest and mutation testing |

Each implementation includes:
- **Test scripts**: `run-tests.sh` (Linux/macOS) and `run-tests.ps1` (PowerShell)
- **Mutation testing**: Add `mutate` parameter to run mutation tests
- **Code coverage**: Automatic coverage reporting

### 🐧 Linux Users

If you're on Linux and encounter permission or line ending issues with the scripts, run this command from the root directory:

```bash
./fix-shell-scripts.sh
```

This will automatically fix line endings and make all shell scripts executable across all implementations.

### 🚀 Getting Started

- **[Workshop Quick Start](Workshop-Quick-Start.md)** - Get started quickly with the workshop exercises
- **[Code Smells Guide](Code-Smells.md)** - Detailed guide to identifying and understanding code smells
