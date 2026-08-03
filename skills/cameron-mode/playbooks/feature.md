### Feature

**You own the design. Plan, review, verify.** Delegate implementation; stay in the lead.

1. `how` over the affected subsystem.
2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`; do not fold the design decision silently into implementation.
3. Write the throughput checkpoint as four todo items. A dimension that genuinely does not apply (single file, no fan-out) keeps its item with `n/a: <reason>` rather than being dropped:
   - **Blocking first steps.** Gates run before fan-out.
   - **Independent workstreams.** Disjoint files, services, or layers parallelize. Shared writes serialize.
   - **Shared mutable state.** Default to splitting the target (the **separate-before-serializing-shared-state** principle skill). Serialize only for real invariants.
   - **Smallest safe decomposition.** If one worker is best, name why.
4. If a work item exists, name `WI{number}` and any reference WI/code the human called canonical. Prefer those patterns when choosing a shape.
5. SDD is optional. Skip unless the human opted in (attached `/sdd-*`, named the pipeline, or asked for it). If opted in: fan phase skills to Composer minions; keep orchestrator gates in the parent.
6. Before implementing nontrivial work the human has not approved: produce a short plan (chat or `plan.md`). Prefer interactive review over a wall of markdown. Offer Plannotator once for long plans or spike docs; do not auto-launch. Wait for implement approval.
7. On approval: plan file is read-only; finish every todo. Parent orchestrates; Composer minions implement nontrivial code per the Planner and workers section of cameron-mode.
8. Delegate code-writing to a `cameron-agent` subagent using your configured feature model with a specific scope (file paths, named data shape and its organizing structure per **principle-model-the-domain** — a state machine over scattered booleans, a table/registry over branching, a typed model over repeated shape assumptions, chosen before the delegate writes logic — and success criteria); review its diff yourself. When the implementation admits multiple valid shapes (error handling, abstraction layer, test structure), delegate via the **arena** skill instead so the runners surface the alternatives and the cross-judge guards the pick. Mandatory: no skip-with-reason escape, and Laziness Protocol does not override it (the gain is review separation, not lines saved). You can spawn a subagent even though you are one; "the app is small" and "a subagent cannot spawn one" are both wrong. A subagent forbidden to spawn satisfies this by owning the diff directly with the same review separation; no "standing by" reply that waits on a nested agent. Comments per **Comments**. Surgical edits, re-ground against the source for upstream-derived files. Port shared-primitive improvements to all consumers and verify each. Commit liberally.
9. Verify on the matching surface. Legacy-aware: tests when they exist; live/manual repro when they do not. Heavy verify may fan to a minion; parent owns done. "Inconclusive" or wrong-surface is not a pass; flag it.
10. Rebase into small, ordered commits; stack follow-ups. Prefer `work-unit-commits` when rewriting history. Use the **sequence-verifiable-units** principle skill, building, verifying, and committing each small unit before the next.
11. If the design is contested, `interrogate` before shipping.
12. Run **Opening an ADO PR** (`playbooks/opening-ado-pr.md`).

Code-coupled work (one feature, one migration) goes to a single owner with the checkpoint inline; that owner fans out internally after the blocking phase. Parent-level fan-out is for slices that produce independent artifacts (audits, cross-subsystem investigations, competing experiments). Rewrite the checkpoint at phase boundaries; spawn a fresh owner rather than chaining interrupts.

**Reply:** what you built, what you chose and why, open decisions, what still needs approval (push/PR), and how you proved it on a legacy-sparse surface when relevant. Tables for design alternatives.
