# Code Smells Quick Guide


| Code Smell | Refactoring patterns to apply |
|---|---|
| **Comments (a.k.a. Deodorant)**: When you feel like writing a comment, first try to refactor so the comment becomes unnecessary. | Rename Method<br>Extract Method<br>Introduce Explaining Variable<br>Extract Class |
| **Long Method**: Too much logic packed into one routine - hard to scan and reason about. | Extract Method<br>Introduce Parameter Object<br>Replace Temp with Query<br>Decompose Conditional |
| **Primitive Obsession**: Raw primitives/strings used where richer domain concepts belong. | Replace Primitive with Value Object<br>Introduce Parameter Object<br>Extract Class<br>Encapsulate Field |
| **Magic Numbers**: Unnamed literals hide meaning and intent. | Replace Magic Number with Symbolic Constant<br>Introduce Constant<br>Introduce Enumeration |
| **Conditional Complexity**: Deeply nested or sprawling conditionals obscure intent. | Decompose Conditional<br>Replace Nested Conditional with Guard Clauses<br>Consolidate Conditional Expression<br>Replace Conditional with Polymorphism |
| **Duplication**: The same logic exists in multiple places. | Extract Method<br>Extract Class/Module<br>Pull Up Method<br>Consolidate Duplicate Conditional Fragments |
| **Bad Names**: Methods/classes/variables don’t reveal purpose. | Rename Method<br>Rename Variable<br>Rename Class<br>Introduce Parameter Object |
| **Dead Code / No-ops**: Code that never runs or has no effect. | Remove Dead Code<br>Inline Function/Variable<br>Delete Unused Declarations |
| **Dead Store**: Values are assigned but never read. | Inline/Remove Variable<br>Remove Assignments to Parameters<br>Split Variable<br>Return Directly |
| **Speculative Generality**: Abstractions added “just in case,” but unused. | Inline Class<br>Collapse Hierarchy<br>Remove Parameter<br>Remove Dead Code |
| **Misleading Constants**: Names/values imply the wrong thing. | Rename Constant<br>Replace Literal with Constant<br>Introduce Enumeration |
| **Swallowed Exceptions**: Errors are caught and ignored, hiding failures. | Introduce Guard Clauses<br>Replace Exception with Precondition<br>Re-throw with Context<br>Extract Try/Catch |
| **Redundant Comparisons**: Unnecessary or repeated boolean checks. | Simplify Conditional Expression<br>Inline Boolean Expression<br>Apply De Morgan Transformations |
| **Unreachable Branch**: Code path that cannot be hit. | Remove Dead Code<br>Simplify Conditional<br>Decompose Conditional |
| **Negative/Inverse Conditionals**: Hard-to-parse negations (e.g., !flag). | Replace Negation with Positive Condition<br>Introduce Guard Clauses<br>Decompose Conditional |
| **Clutter**: Low-value noise—temporary variables, outdated comments, unused imports. | Inline Variable<br>Extract Method<br>Remove Dead Code<br>Organize Imports |
| **Ticket Chatter in Code**: ADO/Rally/Jira/PR references, or conversations that describe history rather than intent. | Remove Comment<br>Extract Method with intention-revealing names<br>Replace Comment with Code |
