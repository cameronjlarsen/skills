# Reference

## Dependency Categories

When assessing a candidate for deepening, classify its dependencies:

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — just merge the modules and test directly.

### 2. Local-substitutable

Dependencies that have local test stand-ins (e.g., PGLite for Postgres, in-memory filesystem). Deepenable if the test substitute exists. The deepened module is tested with the local stand-in running in the test suite.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a port (interface) at the module boundary. The deep module owns the logic; the transport is injected. Tests use an in-memory adapter. Production uses the real HTTP/gRPC/queue adapter.

Recommendation shape: "Define a shared interface (port), implement an HTTP adapter for production and an in-memory adapter for testing, so the logic can be tested as one deep module even though it's deployed across a network boundary."

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.) you don't control. Mock at the boundary. The deepened module takes the external dependency as an injected port, and tests provide a mock implementation.

## Cross-Skill Lens Matrix

Use these lenses only per lens mode and trigger rules in [SKILL.md](SKILL.md).

| Lens | Trigger | Checks (2-4) | Red flags | How it changes recommendation |
|------|---------|--------------|-----------|-------------------------------|
| `software-design-philosophy` | Always in `minimal`; default baseline in `auto/full` | Module depth ratio, interface complexity, information hiding, change amplification | Thin pass-through layers, many knobs on API, leaked implementation details | Prefer smaller surface + deeper module; merge shallow seams |
| `domain-driven-design` | Domain terms, bounded-context seams, aggregates, ACL needs | Ubiquitous language fit, context boundary clarity, aggregate consistency boundary, anti-corruption layer need | Generic technical names, context leakage, giant aggregates, foreign model leakage | Rebound module along domain boundary; add ACL ports at context edges |
| `ddia-systems` | Storage/consistency/replication/partition/transaction/pipeline impact | Consistency model fit, transaction boundary correctness, replication lag tolerance, partition hotspot risk | Hidden cross-partition writes, unstated consistency assumptions, unbounded fanout, fragile retries | Adjust API around consistency guarantees; isolate data-critical paths |
| `system-design` | Scale/latency/throughput/availability/SLO/ops concerns | Capacity assumptions, failure modes, bottleneck placement, migration/runtime risk | No load assumptions, single points of failure, sync chains on slow deps, no rollback path | Favor safer migration path, explicit SLO trade-offs, staged rollout plan |
| `clean-code` | User explicitly asks | Naming clarity, function responsibility, error boundary clarity | Ambiguous names, mixed abstraction levels, side-effect-heavy helpers | Tighten interface naming and caller ergonomics |
| `refactoring-patterns` | User explicitly asks | Smell-to-refactor mapping, sequence safety, branch-by-abstraction need | Big-bang rewrite plan, unclear sequence, no characterization tests | Recommend incremental migration sequence with named refactor steps |

### Guardrails (when not to apply)

- Skip `ddia-systems` for purely in-process candidates with no data boundary risk.
- Skip `system-design` when there are no explicit runtime or scale concerns.
- Skip `domain-driven-design` when candidate is purely technical plumbing with no domain model boundary.
- Skip `clean-code` and `refactoring-patterns` unless user asks.

### Quick Mode Fast Path

- In Quick mode, apply at most one conditional lens unless `lenses=full` is set.
- Choose the single highest-signal conditional lens by observed risk.
- If `lenses=none`, apply zero lenses regardless of risk.

### `lenses=none` semantics

When lens mode is `none`, output:

- `Applied lenses: []`
- `Skipped lenses: [software-design-philosophy, domain-driven-design, ddia-systems, system-design, clean-code, refactoring-patterns] (mode=lenses=none)`

## Testing Strategy

The core principle: **replace, don't layer.**

- Old unit tests on shallow modules are waste once boundary tests exist — delete them
- Write new tests at the deepened module's interface boundary
- Tests assert on observable outcomes through the public interface, not internal state
- Tests should survive internal refactors — they describe behavior, not implementation

## Local RFC Template

Store refactor RFCs as markdown files in `.refactor-issues/`.

- File name: `RI-YYYY-MM-DD-###-kebab-title.md`
- ID format: `RI-YYYY-MM-DD-###`

<rfc-template>

---
id: RI-YYYY-MM-DD-###
title: <short title>
status: open
priority: low|medium|high
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [architecture, refactor]
---

## Problem

Describe the architectural friction:

- Which modules are shallow and tightly coupled
- What integration risk exists in the seams between them
- Why this makes the codebase harder to navigate and maintain

## Proposed Interface

The chosen interface design:

- Interface signature (types, methods, params)
- Usage example showing how callers use it
- What complexity it hides internally

## Dependency Strategy

Which category applies and how dependencies are handled:

- **In-process**: merged directly
- **Local-substitutable**: tested with [specific stand-in]
- **Ports & adapters**: port definition, production adapter, test adapter
- **Mock**: mock boundary for external services

## Testing Strategy

- **New boundary tests to write**: describe the behaviors to verify at the interface
- **Old tests to delete**: list the shallow module tests that become redundant
- **Test environment needs**: any local stand-ins or adapters required

## Implementation Recommendations

Durable architectural guidance that is NOT coupled to current file paths:

- What the module should own (responsibilities)
- What it should hide (implementation details)
- What it should expose (the interface contract)
- How callers should migrate to the new interface

</rfc-template>
