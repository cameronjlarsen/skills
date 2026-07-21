# cameron-mode

Cursor plugin for Cameron's agent style: concise verified work, planner-worker orchestration, Composer minions for nontrivial edits, Azure DevOps/WI shipping, tighter approval gates, and legacy-aware verification.

## Prerequisites

Install the **pstack** plugin first. This plugin depends on pstack for `principle-*` leaf skills and workflow skills (`how`, `why`, `architect`, `interrogate`, `reflect`, `unslop`, and others).

## Usage

- Invoke **`/cameron-mode`** for Cameron's full mode skill.
- Subagents spawned inside playbooks default to **`cameron-agent`**, which reads the cameron-mode skill in full before work.

## Local install

Point Cursor at this directory as a local plugin (Settings → Plugins → add local plugin path), or symlink/copy into your plugins folder. Reload Cursor after install.

## What ships

- `skills/cameron-mode/` — mode skill and playbooks (review findings, merge review, thin Opening an ADO PR wrapper)
- `skills/create-ado-pr/` — standalone Azure DevOps PR workflow (source of truth for ADO shipping)
- `agents/cameron-agent.md` — routing wrapper for `/cameron-mode`

Companion skills referenced by name (`humanizer`, `work-unit-commits`, `cursor-team-kit` `/deslop`) are external. Install them separately when you want those steps.
