---
name: create-ado-pr
description: "Trigger: ADO PR, create-ado-pr, WI branch PR. Open Azure DevOps PR (absinc/Net) with two approval gates; invocable without cameron-mode."
license: Apache-2.0
metadata:
  author: cameron-larsen
  version: "2.2"
---

## Activation Contract

Use when opening an ADO PR on a WI branch, shipping to Azure DevOps, or when the user asks for create-ado-pr / ADO PR creation. Invocable without cameron-mode. Follow this skill for every MCP/CLI call — do not freestyle.

## Hard Rules

| Rule | Detail |
|------|--------|
| Two approval gates | PR approval before push/create/Code Review/reviewers; story points approval before `Custom.StoryPointsActual` |
| MCP schemas first | Read live `user-azure-devops` descriptors before calling; recipes in `references/mcp-cli-calls.md` |
| Work item link | Always associate the WI on create; recover with project ID + repo GUID if missing |
| PR title | `WI{number}: {ticket title}` — not conventional commits |
| Commit messages | Still follow conventional commits on the branch |
| No duplicate PRs | Report existing active PR instead of creating another |
| No git config | Never run `git config` |
| No force-push to protected | Never force-push `dev`/`main`; force-push only if user explicitly requests |
| Preserve Test Notes | Do not overwrite `Custom.TestNotesforQA` unless user requests |
| Skip story points if set | Report existing `Custom.StoryPointsActual` unless user asks to update |
| Mirror reviewers | Only when caller asks; non-`dev` targets only; see `references/reviewer-mirroring.md` |
| PR body | Reviewer-first: TL;DR + Review + Test plan per `references/pr-description.md`; skip Changes table when diff already shows files |
| Defaults | Org/project/target/fields from `references/defaults-and-fields.md`; override only when user specifies |

If the user edits title or description, re-present the PR proposal before proceeding.

## Decision Gates

| Situation | Action |
|-----------|--------|
| No WI ID on branch and user did not supply one | Ask before continuing |
| Active PR already on source branch | Return URL/ID; do not create duplicate; Steps 9–11 OK if user wants WI updates |
| User approves PR / says yes / create it / push and create | Push, create PR, verify, Step 8.5, Code Review + Test Notes |
| User edits title/description | Apply edits; re-propose; wait again |
| Target is `dev` or mirroring not requested | Skip Step 8.5 |
| Already `Code Review` | Skip state transition; still set Test Notes if empty and Feature Flag if unset |
| `Custom.TestNotesforQA` already populated | Preserve; do not overwrite |
| Planned Story Points absent | Treat as unset; estimate actual from git signals alone |
| `Custom.StoryPointsActual` already set | Report value; skip Step 10 re-proposal unless user asks |
| User approves actual points or gives `actual: N` | Update `Custom.StoryPointsActual` only |

## Execution Steps

1. **Resolve WI ID** — regex `WI(\d+)` on branch or user input. See `references/defaults-and-fields.md`.
2. **Fetch WI fields** — include `System.WorkItemType`. MCP then CLI. Load recipes from `references/mcp-cli-calls.md`. Done when title, type, state, Test Notes, and both story-point fields (or their absence) are known.
3. **Check duplicate PR** — active PRs on source branch; stop create if found.
4. **Build change summary** — parallel: `git status`, `git branch -vv`, `git fetch origin dev`, `git log origin/dev..HEAD --oneline`, `git diff --stat origin/dev...HEAD`. Fill `assets/pr-description.md` using `references/pr-description.md` (≤4000 chars). Repo name from `git remote get-url origin`. Retain diff stats/commit count for Step 10. Do not push yet.
5. **Propose PR and STOP** — fill `assets/pr-proposal.md`. If mirroring requested and target ≠ `dev`, run policy discovery now and cache sets (`references/reviewer-mirroring.md`). Wait for PR approval.
6. **Push** (after PR approval) — confirm branch `WI{number}`; `git push -u origin WI{number}` if needed; skip if up to date.
7. **Create PR** (after PR approval) — MCP first, CLI fallback; link WI. See `references/mcp-cli-calls.md`.
8. **Verify PR** — capture URL/ID; recover WI link if refs empty.
8.5. **Mirror reviewers** — apply cached set only; see `references/reviewer-mirroring.md`.
9. **Code Review + Test Notes** — one update: State→`Code Review` (if needed), Test Notes if empty (`N/A` only when no QA impact; cite PR #), and `Custom.FeatureFlagInUse` as string `Yes`/`No` (never boolean). Required for Dev Task→Code Review; set for other types too. Done when that update succeeds. Continue to Step 10.
10. **Propose Story Points Actual and STOP** — rubric in `references/defaults-and-fields.md`; present `assets/story-points-proposal.md`. Wait for story points approval.
11. **Update Story Points Actual** — use user’s number if given; re-fetch to confirm.

## Output Contract

Return: PR URL and ID, linked WI, type, branches, WI state, Feature Flag In Use, Test Notes summary, Story Points Actual (planned → actual; planned may be unset), reviewers attached if mirrored ("Attached N required, M optional" or "not requested").

## References

- `references/defaults-and-fields.md` — org/project defaults, WI fields, ID resolution, estimation rubric
- `references/mcp-cli-calls.md` — MCP/CLI payloads for Steps 2–3, 7–9, 11
- `references/reviewer-mirroring.md` — Step 8.5 discovery and apply
- `references/pr-description.md` — reviewer-first PR body rules
- `assets/pr-description.md` — Step 4 description template
- `assets/pr-proposal.md` — Step 5 proposal template
- `assets/story-points-proposal.md` — Step 10 proposal template
- `references/skill-style-guide.md` — LLM-first skill style contract
