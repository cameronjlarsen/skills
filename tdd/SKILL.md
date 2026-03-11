---
name: tdd
description: Test-driven development with a strict red-green-refactor loop. Use whenever the user wants to write tests first, implement behavior incrementally, reproduce a bug with a failing test, add a regression test before fixing something, protect a refactor with tests, or add characterization tests around legacy code. Also use when the user asks for test-first development, mentions red-green-refactor, asks what test to write next, or wants help choosing the next smallest behavior to test.
---

# Test-Driven Development

Use a strict `RED → GREEN → REFACTOR` loop. One test, one change, one cycle.

## Philosophy

Tests verify behavior through public interfaces — not implementation details. Code can change entirely; tests shouldn't.

- **Good tests**: exercise real code paths through public APIs, describe _what_ the system does, survive refactors
- **Bad tests**: mock internal collaborators, test private methods, break when you rename a function without changing behavior

See [references/tests.md](references/tests.md) for examples and [references/mocking.md](references/mocking.md) for mocking guidelines.

## ⚠️ Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.**

Horizontal slicing produces bad tests — written against imagined behavior, testing shape not semantics, insensitive to real changes. It also encourages shallow designs where too much structure leaks into tests. Prefer deeper modules with stable public contracts. See [references/deep-modules.md](references/deep-modules.md).

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  ...
```

Each cycle informs the next. You can't do that in bulk.

## Planning

Before writing any code:

- [ ] Confirm what interface changes are needed
- [ ] Identify which behaviors to test (prioritize)
- [ ] List behaviors, not implementation steps
- [ ] Design for testability — see [references/interface-design.md](references/interface-design.md)
- [ ] Look for small interfaces with deeper implementations — see [references/deep-modules.md](references/deep-modules.md)
- [ ] Confirm the plan when requirements, interface, or risk are unclear

Ask: _"What should the public interface look like? Which behavior matters most to prove first?"_

**You can't test everything.** Focus on critical paths and complex logic.

## Test Granularity

Choose the narrowest test that still validates meaningful behavior through a stable interface.

Prefer:

- focused domain or application-level tests through a public API
- broader integration tests when the boundary itself is what matters
- mocks at system boundaries only for external systems you do not control

Avoid full-stack or highly coupled tests when a smaller behavior test would prove the same thing more clearly.

## Workflow

### 1. Tracer Bullet

Write ONE test that proves ONE meaningful behavior end-to-end enough to validate the path:

```
RED:   Write test for first behavior → fails for the right reason
GREEN: Write minimal code to pass → passes
```

This is your tracer bullet — proves the path works before you build the rest.

### 2. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
RUN:   Run the smallest relevant test scope
GREEN: Minimal code to pass → passes
RUN:   Re-run that scope to confirm green
```

Rules:
- One test at a time
- Only enough code to pass the current test
- Don't anticipate future tests
- Keep tests focused on observable behavior
- Prefer the smallest fast feedback loop that still proves the behavior

After completing a small slice, run a broader relevant suite to catch unexpected breakage between components.

### 3. Refactor

After all tests pass — see [references/refactoring.md](references/refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after every step

**Never refactor while RED.**

## By Task Type

### New feature
1. Start with the smallest user-visible behavior.
2. Add tests incrementally until the feature is complete.

### Bug fix
1. Reproduce the bug with a failing test first.
2. Fix only enough code to make that test pass.
3. Keep the regression test.

### Refactor / legacy code
1. Add characterization tests for current observable behavior first.
2. Capture behavior at the public seam where possible.
3. Do not accidentally lock in a known bug unless that behavior is explicitly desired.
4. Break hard dependencies at seams (parameterization, extraction, DI).
5. Refactor in small steps with tests green throughout.

## Cycle Checklist

```
[ ] Test describes behavior, not implementation
[ ] Test uses a stable public interface or intentional system boundary
[ ] Test would survive internal refactor
[ ] Failure proves the behavior is missing
[ ] Code is minimal for this test
[ ] No speculative features added
```

## Stop Conditions

Correct course if:
- new test passes before the code change
- failure message doesn't prove the missing behavior
- adding lots of code before re-running tests
- tests depend on internal calls or incidental structure
- test scope is broader than needed for the behavior being proved

## .NET / NUnit

For C# and VB.NET projects using NUnit, the red-green-refactor loop is identical. Framework-specific notes:

- **Fixture layout, assertions, parameterized tests** → [references/dotnet/dotnet-nunit.md](references/dotnet/dotnet-nunit.md)
- **`async Task` tests, async SetUp/TearDown, timeouts** → [references/dotnet/dotnet-async-testing.md](references/dotnet/dotnet-async-testing.md)
- **VB.NET syntax differences, `[Is]` escape, mixed-project tips** → [references/dotnet/dotnet-vb-notes.md](references/dotnet/dotnet-vb-notes.md)

Key differences from JS/TS: use `Assert.That(actual, Is.EqualTo(expected))` constraint style; name tests `Method_Condition_ExpectedBehavior`.

## References

- [references/tests.md](references/tests.md) — good vs bad test examples
- [references/mocking.md](references/mocking.md) — when and how to mock
- [references/refactoring.md](references/refactoring.md) — refactor candidates checklist
- [references/interface-design.md](references/interface-design.md) — interfaces for testability
- [references/deep-modules.md](references/deep-modules.md) — module depth and public surface
- [references/dotnet/dotnet-nunit.md](references/dotnet/dotnet-nunit.md) — NUnit fixture, assertions, parameterized tests
- [references/dotnet/dotnet-async-testing.md](references/dotnet/dotnet-async-testing.md) — async test patterns (.NET)
- [references/dotnet/dotnet-vb-notes.md](references/dotnet/dotnet-vb-notes.md) — VB.NET syntax + mixed-project notes
