# Code Smells Quick Guide


| Smell (name + short description) | Refactoring patterns to apply |
|---|---|
| **Comments (a.k.a. Deodorant)**: When you feel like writing a comment, first try to refactor so the comment becomes unnecessary. | Rename Method; Extract Method; Introduce Explaining Variable; Extract Class |
| **Long Method**: Too much logic packed into one routine; hard to scan and reason about. | Extract Method; Introduce Parameter Object; Replace Temp with Query; Decompose Conditional |
| **Primitive Obsession**: Raw primitives/strings used where richer domain concepts belong. | Replace Primitive with Value Object; Introduce Parameter Object; Extract Class; Encapsulate Field |
| **Magic Numbers**: Unnamed literals hide meaning and intent. | Replace Magic Number with Symbolic Constant; Introduce Constant; Introduce Enumeration |
| **Conditional Complexity**: Deeply nested or sprawling conditionals obscure intent. | Decompose Conditional; Replace Nested Conditional with Guard Clauses; Consolidate Conditional Expression; Replace Conditional with Polymorphism |
| **Duplication**: The same logic exists in multiple places. | Extract Method; Extract Class/Module; Pull Up Method; Consolidate Duplicate Conditional Fragments |
| **Bad Names**: Methods/classes/variables don’t reveal purpose. | Rename Method; Rename Variable; Rename Class; Introduce Parameter Object |
| **Dead Code / No-ops**: Code that never runs or has no effect. | Remove Dead Code; Inline Function/Variable; Delete Unused Declarations |
| **Dead Store**: Values are assigned but never read. | Inline/Remove Variable; Remove Assignments to Parameters; Split Variable; Return Directly |
| **Speculative Generality**: Abstractions added “just in case,” but unused. | Inline Class; Collapse Hierarchy; Remove Parameter; Remove Dead Code |
| **Misleading Constants**: Names/values imply the wrong thing. | Rename Constant; Replace Literal with Constant; Introduce Enumeration |
| **Swallowed Exceptions**: Errors are caught and ignored, hiding failures. | Introduce Guard Clauses; Replace Exception with Precondition; Re-throw with Context; Extract Try/Catch |
| **Redundant Comparisons**: Unnecessary or repeated boolean checks. | Simplify Conditional Expression; Inline Boolean Expression; Apply De Morgan Transformations |
| **Unreachable Branch**: Code path that cannot be hit. | Remove Dead Code; Simplify Conditional; Decompose Conditional |
| **Negative/Inverse Conditionals**: Hard-to-parse negations (e.g., !flag). | Replace Negation with Positive Condition; Introduce Guard Clauses; Decompose Conditional |
| **Clutter**: Low-value noise—temporary variables, outdated comments, unused imports. | Inline Variable; Extract Method; Remove Dead Code; Organize Imports |
| **Ticket Chatter in Code**: ADO/Rally/Jira/PR references, or conversations that describe history rather than intent. | Remove Comment; Extract Method with intention-revealing names; Replace Comment with Code |
