# cameron-mode

Cursor plugin for Cameron's agent style: concise verified work, planner-worker orchestration, Composer minions for nontrivial edits, Azure DevOps/WI shipping, tighter approval gates, and legacy-aware verification.

## Prerequisites

Install the **pstack** plugin first. This plugin depends on pstack for `principle-*` leaf skills and workflow skills (`how`, `why`, `architect`, `interrogate`, `reflect`, `unslop`, and others).

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

- `skills/cameron-mode/` — mode skill and playbooks (review findings, merge review, thin Opening an ADO PR wrapper)
- `skills/create-ado-pr/` — standalone Azure DevOps PR workflow (source of truth for ADO shipping)
- `agents/cameron-agent.md` — routing wrapper for `/cameron-mode`

Companion skills referenced by name (`humanizer`, `work-unit-commits`, `cursor-team-kit` `/deslop`) are external. Install them separately when you want those steps.
