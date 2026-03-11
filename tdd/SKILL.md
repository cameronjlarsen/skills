---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, asks for test-first development, or needs to add characterization tests around legacy code.
---

# Test-Driven Development

Use a strict `RED → GREEN → REFACTOR` loop. One test, one change, one cycle.

## Philosophy

Tests verify behavior through public interfaces — not implementation details. Code can change entirely; tests shouldn't.

- **Good tests**: exercise real code paths through public APIs, describe _what_ the system does, survive refactors
- **Bad tests**: mock internal collaborators, test private methods, break when you rename a function without changing behavior

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## ⚠️ Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.**

Horizontal slicing produces bad tests — written against imagined behavior, testing shape not semantics, insensitive to real changes. It also encourages shallow designs where too much structure leaks into tests. Prefer deeper modules with stable public contracts. See [deep-modules.md](deep-modules.md).

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
- [ ] Design for testability — see [interface-design.md](interface-design.md)
- [ ] Look for small interfaces with deeper implementations — see [deep-modules.md](deep-modules.md)
- [ ] Get approval on the plan

Ask: _"What should the public interface look like? Which behaviors matter most?"_

**You can't test everything.** Focus on critical paths and complex logic.

## Workflow

### 1. Tracer Bullet

Write ONE test that proves ONE thing end-to-end:

```
RED:   Write test for first behavior → fails
GREEN: Write minimal code to pass → passes
```

This is your tracer bullet — proves the path works before you build the rest.

### 2. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:
- One test at a time
- Only enough code to pass the current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 3. Refactor

After all tests pass — see [refactoring.md](refactoring.md):

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
1. Add characterization tests for current behavior first.
2. Break hard dependencies at seams (parameterization, extraction, DI).
3. Refactor in small steps with tests green throughout.

## Cycle Checklist

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

## Stop Conditions

Correct course if:
- new test passes before the code change
- failure message doesn't prove the missing behavior
- adding lots of code before re-running tests
- tests depend on internal calls or incidental structure

## .NET / NUnit

For C# and VB.NET projects using NUnit, the red-green-refactor loop is identical. Framework-specific notes:

- **Fixture layout, assertions, parameterized tests** → [dotnet-nunit.md](dotnet-nunit.md)
- **`async Task` tests, async SetUp/TearDown, timeouts** → [dotnet-async-testing.md](dotnet-async-testing.md)
- **VB.NET syntax differences, `[Is]` escape, mixed-project tips** → [dotnet-vb-notes.md](dotnet-vb-notes.md)

Key differences from JS/TS: use `Assert.That(actual, Is.EqualTo(expected))` constraint style; name tests `Method_Condition_ExpectedBehavior`.

## References

- [tests.md](tests.md) — good vs bad test examples
- [mocking.md](mocking.md) — when and how to mock
- [refactoring.md](refactoring.md) — refactor candidates checklist
- [interface-design.md](interface-design.md) — interfaces for testability
- [deep-modules.md](deep-modules.md) — module depth and public surface
- [dotnet-nunit.md](dotnet-nunit.md) — NUnit fixture, assertions, parameterized tests
- [dotnet-async-testing.md](dotnet-async-testing.md) — async test patterns (.NET)
- [dotnet-vb-notes.md](dotnet-vb-notes.md) — VB.NET syntax + mixed-project notes
