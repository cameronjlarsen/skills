# cameron-mode

Cursor plugin for Cameron's agent style: concise verified work, planner-worker orchestration, Composer minions for nontrivial edits, Azure DevOps/WI shipping, tighter approval gates, and legacy-aware verification.

## Prerequisites

Install the **pstack** plugin first. This plugin depends on pstack for `principle-*` leaf skills, workflow skills (`how`, `why`, `architect`, `interrogate`, `reflect`, `unslop`, and others), and for Phase A **poteto-mode** playbooks that cameron-mode routes instead of forking (investigation, prototype, pause/session pickup, forensics).

After updating pstack, optionally run `pwsh ./scripts/sync-from-pstack.ps1` to assert routed playbooks stay unforked and cameron-owned ship playbooks did not regress to GitHub/`gh` paths.

## Usage

- Invoke **`/cameron-mode`** for Cameron's full mode skill.
- Subagents spawned inside playbooks default to **`cameron-agent`**, which reads the cameron-mode skill in full before work.

## Local install

Preferred (skills under `~/.agents`, stays synced with this repo):

1. Junction the skills:
   - `~/.agents/skills/cameron-mode` → `skills/cameron-mode`
   - `~/.agents/skills/create-ado-pr` → `skills/create-ado-pr`
2. Junction the plugin so `cameron-agent` registers:
   - `~/.cursor/plugins/local/cameron-mode` → this repo root
3. Reload Window (`Developer: Reload Window`).

Alternates: Cursor “add from folder” UI, or only the plugin junction (skills then load from the plugin, not `~/.agents`).

## What ships

- `skills/cameron-mode/` — mode skill and cameron-owned playbooks (babysit, feature/bug-fix overlays, review findings, merge review, Opening an ADO PR). Identical poteto playbooks are routed to the pstack plugin, not copied here.
- `skills/create-ado-pr/` — standalone Azure DevOps PR workflow (source of truth for ADO shipping)
- `skills/work-unit-commits/` — commit-shaping skill for reviewable work units and stacked PRs
- `agents/cameron-agent.md` — routing wrapper for `/cameron-mode`

Companion skills referenced by name (`humanizer`, `cursor-team-kit` `/deslop`) are external. Install them separately when you want those steps.
