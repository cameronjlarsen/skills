### Opening an ADO PR

Invoked at the end of every shipping playbook when a PR is needed.

**Before any step below:** load and follow the **create-ado-pr** skill (`skills/create-ado-pr/SKILL.md`) for org defaults, MCP/CLI shapes, field names, WI-link recovery, reviewer mirroring, approval gates, and critical rules. Copy these numbered steps into the todolist for scanning. Execute via create-ado-pr — do not freestyle from these bullets alone, and do not duplicate its long procedure here.

**Cameron notes**

- **Worktree.** Prefer a worktree off the right base; fresh worktree when the checkout is dirty with unrelated work.
- **Commits.** Small, ordered, landable commits. Prefer `work-unit-commits` when reshaping. `/deslop` before commit when available. Before review, `/no-comments` when the pstack plugin is installed. **humanizer** + **technical-writing** + **unslop** on PR body and commit messages meant for humans.
- **Babysit.** After create, run **Babysit** (`playbooks/babysit.md`) only if the human wants the PR watched.
- **Findings.** Skeptical bot posture applies after the propose-before-code gate on new findings (`playbooks/review-findings.md`).

1. Run **create-ado-pr** Steps 1–4 (resolve WI, fetch fields, duplicate check, change summary).
2. Draft the PR proposal via create-ado-pr Step 5. **Do not push. Do not create the PR.** Stop for its PR approval gate.
3. After explicit PR approval, continue create-ado-pr Steps 6–9 (push, create, verify, optional reviewer mirror, WI → Code Review + Test Notes).
4. Stop again for create-ado-pr Steps 10–11 (Story Points Actual proposal and update).
5. Reply with proposal awaiting approval, or PR URL after create, plus WI state and story points when set.

**Opt-in:** mirror `dev` reviewers onto non-`dev` targets when asked (create-ado-pr Step 8.5).
