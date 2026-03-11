# Refactor Candidates

Run this checklist after all tests pass. Never refactor while RED.

## What to Look For

- **Duplication** → extract function or class
- **Long methods** → break into private helpers (keep tests on the public interface)
- **Shallow modules** → combine or deepen; push complexity behind a simpler interface
- **Feature envy** → move logic to where the data lives
- **Primitive obsession** → introduce value objects
- **Existing code** the new code reveals as problematic → fix it now while the context is fresh

### Primitive Obsession Example

TypeScript — branded types make illegal states unrepresentable:

```typescript
// Before: primitives everywhere
function createUser(id: string, email: string) { ... }

// After: value objects
type UserId = { readonly _brand: "UserId"; value: string };
type Email  = { readonly _brand: "Email";  value: string };

function createUser(id: UserId, email: Email) { ... }
```

C# — sealed records enforce the same constraint:

```csharp
public sealed record UserId(Guid Value);
public sealed record EmailAddress(string Value);

public sealed record User(UserId Id, EmailAddress Email);
```

## Rules

- Run tests after every refactor step
- Keep the public interface stable — tests should not need to change
- Stop when the code is clear, not when it's perfect
