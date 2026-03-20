---
name: improve-codebase-architecture
description: Find and fix architectural friction by identifying shallow, tightly-coupled modules and proposing deeper, testable module boundaries. Use whenever the user mentions architecture cleanup, refactor planning, module boundaries, coupling, integration seams, hard-to-test code, or says devs/AI get lost navigating the repo, even if they never say "deep module".
---

# Improve Codebase Architecture

Explore a codebase like an AI would, surface architectural friction, discover opportunities for improving testability, and propose module-deepening refactors as local RFC files.

A **deep module** (John Ousterhout, "A Philosophy of Software Design") has a small interface hiding a large implementation. Deep modules are more testable, more AI-navigable, and let you test at the boundary instead of inside.

## When To Use

Use this skill when the user asks for any of these outcomes:

- Architecture cleanup or refactor direction across multiple files/modules
- Better module boundaries or reduced coupling
- Better testability via boundary tests instead of brittle internal tests
- Consolidating tightly-coupled areas with high integration risk
- Improving repo navigability for humans and AI agents

## When Not To Use

Do not use this skill for:

- Single-file cleanup, formatting, naming tweaks, or straightforward bugfixes
- Pure implementation tasks where boundaries are already clear
- Cases where user only wants code changes now and no design exploration

## Modes

- **Full mode (default):** Explore broadly, propose multiple candidates, design 3+ interfaces in parallel.
- **Quick mode (on user signal):** If user says "quick", "fast", "just one", or similar, return one top candidate and two interface options.

## Lens Modes (optional)

Cross-skill checks are optional and mode-driven.

- **`lenses=auto` (default):** Run only triggered lenses.
- **`lenses=minimal`:** Run only `software-design-philosophy` core checks.
- **`lenses=full`:** Run all lenses.
- **`lenses=none`:** Run zero cross-skill lenses.

Mode override rule: mode beats tier. If `lenses=none`, run no lenses even if a lens would otherwise be required.

Lens tiers:

- **Core lens:** `software-design-philosophy` (deep module depth, information hiding, interface complexity)
- **Conditional lenses:** `domain-driven-design`, `ddia-systems`, `system-design`
- **On-demand lenses:** `clean-code`, `refactoring-patterns` (only when user asks for these checks)

Trigger rules for `lenses=auto`:

- Run `domain-driven-design` when candidate boundaries align to domain terms, bounded contexts, aggregates, or anti-corruption seams.
- Run `ddia-systems` when candidate crosses consistency, replication, partitioning, transaction, or data pipeline boundaries.
- Run `system-design` when candidate has explicit scale, latency, throughput, availability, SLO, or operational concerns.
- Do not run `clean-code` or `refactoring-patterns` unless user explicitly requests them.

## Process

### 1. Explore the codebase

Use the `Task` tool with `subagent_type=explore` to navigate the codebase naturally. Do not follow rigid heuristics; explore organically and note where you experience friction.

Minimum coverage floor for repeatable quality:

- Trace at least 3 meaningful call chains end-to-end
- Inspect at least 2 test areas (or confirm meaningful test absence)
- Inspect at least 1 high-churn or recent bug-prone area (git history, issue references, or obvious hotspots)

Look for these signals:

- Where does understanding one concept require bouncing between many small files?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested, or hard to test?

The friction you encounter IS the signal.

### 2. Present candidates

Present a numbered list of deepening opportunities. For each candidate, show:

- **Cluster**: Which modules/concepts are involved
- **Why they're coupled**: Shared types, call patterns, co-ownership of a concept
- **Dependency category**: See [REFERENCE.md](REFERENCE.md) for the four categories
- **Test impact**: What existing tests would be replaced by boundary tests
- **Severity (1-5)**: Architectural cost of leaving this as-is
- **Confidence (low|medium|high)**: How strong the evidence is
- **Migration cost (S|M|L)**: Estimated effort/risk to migrate callers

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### Local RFC store

Use local markdown files, not GitHub issues.

- Directory: `.refactor-issues/` (create if missing)
- Filename: `RI-YYYY-MM-DD-###-kebab-title.md`
- ID in file: `RI-YYYY-MM-DD-###`
- Status values: `open | in_progress | done | rejected`
- If a related RFC exists, update it instead of creating a duplicate
- Next ID rule: for today's date, scan existing IDs and use next available `###` (zero-padded)
- Dedupe rule: treat as related if module cluster overlaps and problem statement is materially the same

### 3. User picks a candidate

### 4. Frame the problem space

Before spawning sub-agents, write a user-facing explanation of the problem space for the chosen candidate:

- The constraints any new interface would need to satisfy
- The dependencies it would need to rely on
- A rough illustrative code sketch to make the constraints concrete — this is not a proposal, just a way to ground the constraints

Show this to the user, then immediately proceed to Step 5. The user reads and thinks about the problem while the sub-agents work in parallel.

### 4.5 Run cross-skill lenses (optional)

Apply lenses according to lens mode and trigger rules.

- `lenses=none`: skip all lenses.
- `lenses=minimal`: apply only `software-design-philosophy`.
- `lenses=auto`: apply `software-design-philosophy` plus triggered conditional lenses.
- `lenses=full`: apply all lenses.

In Quick mode, apply at most one conditional lens unless `lenses=full` is explicitly set.

For transparency, always include:

- `Applied lenses: [<lens names>]`
- `Skipped lenses: [<lens names>] (<reason>)`

For `lenses=none`, output exactly:

- `Applied lenses: []`
- `Skipped lenses: [software-design-philosophy, domain-driven-design, ddia-systems, system-design, clean-code, refactoring-patterns] (mode=lenses=none)`

### 5. Design multiple interfaces

In Full mode, spawn 3+ sub-agents in parallel using the `Task` tool. Each must produce a **radically different** interface for the deepened module.

In Quick mode, produce 2 materially different interfaces (minimized and common-caller-optimized).

Prompt each sub-agent with a separate technical brief (file paths, coupling details, dependency category, what's being hidden). This brief is independent of the user-facing explanation in Step 4. Give each agent a different design constraint:

- Agent 1: "Minimize the interface — aim for 1-3 entry points max"
- Agent 2: "Maximize flexibility — support many use cases and extension"
- Agent 3: "Optimize for the most common caller — make the default case trivial"
- Agent 4 (if applicable): "Design around the ports & adapters pattern for cross-boundary dependencies"

Each sub-agent outputs:

1. Interface signature (types, methods, params)
2. Usage example showing how callers use it
3. What complexity it hides internally
4. Dependency strategy (how deps are handled — see [REFERENCE.md](REFERENCE.md))
5. Trade-offs

Present designs sequentially, then compare them using this fixed rubric:

- Testability (boundary-test quality)
- API simplicity (surface area and cognitive load)
- Migration risk (caller update blast radius)
- Runtime risk (perf, reliability, failure behavior)
- Extensibility (future requirements without interface churn)

After comparing, give your own recommendation: which design you think is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not just a menu.

### 6. User picks an interface (or accepts recommendation)

### 7. Create local RFC file

Create or update a refactor RFC file in `.refactor-issues/` using the template in [REFERENCE.md](REFERENCE.md). Do NOT ask the user to review before creating. Share the RFC ID and file path.

## Anti-Patterns

Avoid these failure modes:

- Over-splitting: creating more tiny modules when deepening should reduce seams
- Testability theater: extracting trivial pure functions while integration risk remains
- Path-coupled guidance: recommendations that break when files move
- Premature interface proposals before proving coupling/problem shape
- Non-discriminating options: presenting many designs that differ only superficially

## Output Templates

Use these templates to keep output predictable and easy to review.

### Candidate List

```markdown
1. <short title>
   - Cluster: <modules/concepts>
   - Why coupled: <shared types/calls/ownership>
   - Dependency category: <in-process|local-substitutable|ports-adapters|mock>
   - Test impact: <what boundary tests replace>
   - Severity: <1-5>
   - Confidence: <low|medium|high>
   - Migration cost: <S|M|L>
```

### Design Comparison

```markdown
## Interface options for <candidate>

### Option A - <label>
- Signature: <types/methods>
- Example: <caller usage>
- Hidden complexity: <what moves inside>
- Dependency strategy: <category + approach>
- Trade-offs: <key trade-offs>

### Option B - <label>
...

### Comparison (rubric)
- Testability: ...
- API simplicity: ...
- Migration risk: ...
- Runtime risk: ...
- Extensibility: ...

### Recommendation
<strong opinion + why>
```

### RFC Handoff

```markdown
Created/updated RFC: <RI-YYYY-MM-DD-###>
Path: `.refactor-issues/<filename>.md`
Next action: <smallest practical migration step>
```
