# cameron-mode

Cursor plugin for Cameron's agent style: concise verified work, planner-worker orchestration, Composer minions for nontrivial edits, Azure DevOps/WI shipping, tighter approval gates, and legacy-aware verification.

## Prerequisites

Install the **pstack** plugin first. This plugin depends on pstack for `principle-*` leaf skills and workflow skills (`how`, `why`, `architect`, `interrogate`, `reflect`, `unslop`, and others).

## Usage

- Invoke **`/cameron-mode`** for Cameron's full mode skill.
- Subagents spawned inside playbooks default to **`cameron-agent`**, which reads the cameron-mode skill in full before work.

## Local install

1. Symlink/junction this repo under `~/.cursor/plugins/local/cameron-mode`, **or**
2. Use Cursor’s “add from folder” UI (requires `.cursor-plugin/marketplace.json` in this repo).
3. Reload Window (`Developer: Reload Window`).

## What ships

- `skills/cameron-mode/` — mode skill and playbooks (review findings, merge review, thin Opening an ADO PR wrapper)
- `skills/create-ado-pr/` — standalone Azure DevOps PR workflow (source of truth for ADO shipping)
- `agents/cameron-agent.md` — routing wrapper for `/cameron-mode`

Companion skills referenced by name (`humanizer`, `work-unit-commits`, `cursor-team-kit` `/deslop`) are external. Install them separately when you want those steps.
