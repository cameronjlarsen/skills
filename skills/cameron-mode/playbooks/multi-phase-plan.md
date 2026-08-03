### Multi-phase or multi-PR plan

Follow [../references/plan.md](../references/plan.md), then apply these Cameron additions:

1. Name WI stack order when branches are `WI{number}` (which WI sits on which base). Prefer the human's stack intent.
2. One PR with work-unit commits is fine when they want a single story. Stacked ADO PRs when they ask for stack / rebase onto another WI.
3. Use worktrees so stack surgery does not interrupt unrelated work.
4. Each PR open uses `playbooks/opening-ado-pr.md` with approval gates. Do not force-push unless they explicitly ask.

**Reply:** stack order (base → tip), what is ready, approval asks.
