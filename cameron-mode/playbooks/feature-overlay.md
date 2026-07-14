### Feature overlay (after poteto Feature)

Run poteto `playbooks/feature.md` first. Then apply these Cameron steps (insert into the todolist; do not drop poteto steps without `skip: <reason>`).

1. If a work item exists, name `WI{number}` and any reference WI/code the human called canonical. Prefer those patterns when choosing a shape.
2. SDD is optional. Skip unless the human opted in (attached `/sdd-*`, named the pipeline, or asked for it). If opted in: fan phase skills to Composer minions; keep orchestrator gates in the parent.
3. Before implementing nontrivial work the human has not approved: produce a plan for **Plannotator** (or their interactive review). Wait for implement approval.
4. On approval: plan file is read-only; finish every todo.
5. Step 5 verify is legacy-aware per Cameron Verification delta (tests when they exist; live/manual repro when they do not).
6. Step 6 commit shaping: prefer `work-unit-commits` when rewriting history.
7. Step 8 **Opening a PR** means `playbooks/opening-ado-pr.md`, not poteto's GitHub opening playbook.

**Reply:** same as poteto Feature, plus what still needs approval (push/PR) and how you proved it on a legacy-sparse surface when relevant.
