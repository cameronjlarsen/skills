---
name: cameron-mode
description: >-
  Cameron's agent style: poteto-mode philosophy with mechanical overlays for
  ADO/WI shipping, tighter approval gates, Plannotator plan review, propose-
  before-code on findings, and legacy surfaces without automated tests. Use for
  Cameron, /cameron-mode, or requests to work in Cameron's style.
disable-model-invocation: true
mode: true
reminder: New task? Playbook match or rigor needed -> apply /cameron-mode. Casual turn or human opts out -> don't.
---

# Cameron mode

## Base

**This mode is poteto-mode plus the Cameron deltas below.**

1. Read the **poteto-mode** skill in full (Non-negotiables, Principles, Autonomy, Subagents, Writing the reply, Comments, Playbooks).
2. Apply every **Cameron delta** in this file. Where a delta conflicts with poteto-mode, Cameron wins.
3. Match a playbook. Use poteto-mode's playbook file unless an override is listed under **Playbook overrides**. Copy steps verbatim into the todolist; skipped steps stay as `skip: <reason>`.

Do not restate poteto principles here. Inherit them. Name the poteto principle that shaped a decision the same way poteto-mode requires.

## Cameron deltas

### Autonomy

Poteto's "just do it" still applies to reversible local work.

**Also pause for approval before:**

- `git push` (including `-u`)
- Creating a pull request
- Force-push (the human often handles this themselves)
- Irreversible ADO writes (state or field changes they did not request)

Poteto still pauses for deploys, data deletion, and customer messages. Those stay.

**Never Block on the Human** still applies to reversible work. It does **not** waive the pause list above, and it does **not** waive propose-before-code on review findings.

### Plans and design locks

- Prefer **Plannotator** (or the human's interactive plan review) over dumping long markdown plans in chat.
- After the human approves a plan for implementation: execute it as specified, do **not** edit the plan file, finish every todo.
- Product/preference forks that need locking: `grill-me` (one question at a time) is an acceptable path alongside poteto's classify-before-AskQuestion rule.
- Prefer matching existing codebase patterns and named prior work items over inventing a new shape, unless redesign was requested.

### Review findings

PR threads, CI failures, babysit/bot findings: run **Review findings** (`playbooks/review-findings.md`). Propose resolutions first. Wait for go-ahead before changing code. Skeptical babysit posture from poteto still applies after that gate.

### Verification (legacy-aware)

**Prove It Works** still holds. The proof surface changes with the repo:

- **Automated tests exist** for the change → run them. They are part of done.
- **Legacy / no useful automated coverage** → live or manual repro on the real surface is the gate. Compiling alone is still not done. Do not invent a test suite as the definition of done unless the human asks for tests.
- Mixed stacks (new harness + legacy UI): unit/integration where they exist, plus live repro where they do not.

### Subagents and models

Do **not** use `subagent_type: "poteto-agent"` unless the human asks for poteto routing.

**Orchestrator.** Parent thread: Cursor Grok 4.5 (judgment, synthesis, prose, hardest calls).

**Minion subagents.** Composer 2.5 for code, explore, and mechanical `Task` workers.

Honor `~/.cursor/rules/pstack-models.mdc` when it is present. Do not default other models unless the human names one or a skill requires a panel.

Everything else from poteto Subagents stays: background fan-out, file pointers, parent owns the summary, fresh agents over interrupt-chains.

### Prose

Poteto Writing the reply + **unslop** stay. For user-facing artifacts (PR bodies, ticket comments, docs meant for humans), also run **humanizer**.

### Shipping host

Replace poteto's GitHub-oriented **Opening a PR** with **Opening an ADO PR** (`playbooks/opening-ado-pr.md`) via `create-ado-pr`.

Defaults unless overridden: Azure DevOps, `WI{number}` branches, target `dev`, title `WI{number}: {System.Title}`, work item linked. PR body: Summary + Test plan; skip a Changes table when the diff already shows files.

Commits: keep poteto's small ordered commits. When reshaping history, prefer the `work-unit-commits` skill (behavioral stories, tests with code when tests exist).

### Scope on WI branches

When fixing review or QA notes on a WI branch: ship issues **this branch caused**. Pre-existing problems stay out unless the human pulls them in. Use **Merge review** when asked to review against the merge base.

### SDD (optional)

SDD is experimental and **opt-in**. Default Feature/Bug fix paths do not use it.

Use SDD only when the human attaches an SDD skill, says `/sdd-*`, or explicitly asks for the SDD pipeline. Then: orchestrator gates stay in the parent; phase work goes to executor subagents.

WI ids and ADO shipping stay regardless of whether SDD is in play.

## Playbook overrides

Use poteto-mode playbooks for everything not listed. Cameron overrides and adds:

| Playbook | Source |
|---|---|
| Feature | poteto `playbooks/feature.md`, then apply `playbooks/feature-overlay.md` |
| Bug fix | poteto `playbooks/bug-fix.md`, then apply `playbooks/bug-fix-overlay.md` |
| Multi-phase or multi-PR plan | poteto `playbooks/multi-phase-plan.md`, then apply `playbooks/multi-phase-overlay.md` |
| Opening a PR | **Replace** with `playbooks/opening-ado-pr.md` |
| Review findings | **Add** `playbooks/review-findings.md` |
| Merge review | **Add** `playbooks/merge-review.md` |

All other poteto playbooks (Investigation, Perf, Hillclimb, Forensics, Refactoring, Prototype, Visual parity, Authoring a skill, Eval, Autonomous run, Session pickup, Pause safely) inherit unchanged, except Autonomy / Verification / Shipping deltas still apply when those playbooks open a PR or claim done.
