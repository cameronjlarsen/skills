---
name: create-ado-pr
description: >-
  Open an Azure DevOps pull request on a WI branch with TMO/absinc defaults,
  two approval gates, work-item link, Code Review transition, Test Notes for QA,
  and Story Points Actual. Use when opening an ADO PR, creating a PR for a WI
  branch, shipping to Azure DevOps, or when the user asks for create-ado-pr /
  ADO PR creation — invocable without cameron-mode.
---

# Create ADO PR

Standalone workflow for opening an Azure DevOps PR on a work-item branch. Agents must follow this file for every MCP/CLI call. Do not freestyle.

## Defaults (TMO / absinc)

| Setting | Default |
|---------|---------|
| Organization | `https://absinc.visualstudio.com` |
| Project | `Net` |
| Target branch | `dev` (`refs/heads/dev`) |
| Source branch | `WI{number}` (`refs/heads/WI{number}`) |
| PR title | `WI{number}: {System.Title}` |
| Work item link | Required on create |

Override target branch, project, or org only when the user specifies.

## Field reference (User Story on Net)

| UI label | Reference name |
|----------|----------------|
| Story Points (planned) | `Microsoft.VSTS.Scheduling.StoryPoints` |
| Story Points Actual | `Custom.StoryPointsActual` |
| Test Notes for QA | `Custom.TestNotesforQA` |
| State | `System.State` → `Code Review` |

Other work item types may use different fields — fetch the item first and confirm.

## Workflow

```
1. Resolve work item ID from branch or user input
2. Fetch ticket title and WI fields (ADO MCP, then Azure CLI fallback)
3. Check for existing open PR on the branch
4. Build change summary from git
5. Propose PR — present full preview and STOP for approval
6. Push branch (only after explicit PR approval)
7. Create PR (ADO MCP first, Azure CLI fallback — only after PR approval)
8. Verify PR and report URL
8.5. Mirror dev reviewers onto PR (opt-in, non-dev targets only)
9. Move work item to Code Review + set Test Notes for QA
10. Propose Story Points Actual — STOP for second approval
11. Update Story Points Actual on ticket (only after story points approval)
```

## Two approval gates (mandatory)

| Gate | Trigger | Allowed actions |
|------|---------|-----------------|
| PR approval | User says approve / yes / create it / push and create | `git push`, `repo_create_pull_request`, WI → Code Review, reviewer attachment (Step 8.5) |
| Story points approval | User approves proposed actual points or gives a number (e.g. `actual: 5`) | `wit_update_work_item` for `Custom.StoryPointsActual` only |

Reviewer attachment (Step 8.5) runs automatically after PR creation under the **PR approval** gate — no separate approval needed.

Never push or create the PR until PR approval. Never update `Custom.StoryPointsActual` until story points approval. If the user edits title or description, apply changes and re-present the PR proposal before proceeding.

## Step 1 — Resolve work item ID

Parse from the current branch name with regex `WI(\d+)` (case-insensitive).

| Input | Numeric ID | Branch prefix |
|-------|------------|---------------|
| Branch `WI18954` | `18954` | `WI18954` |
| User says `18954` | `18954` | `WI18954` |
| User says `WI18954` | `18954` | `WI18954` |

If the branch does not match and the user did not supply an ID, ask before continuing.

## Step 2 — Fetch ticket title and WI fields

**Prefer ADO MCP.** Read the tool schema before calling.

```
CallMcpTool server=user-ado toolName=wit_get_work_item
  id: {numeric_id}
  project: "Net"
  fields:
    - System.Title
    - System.State
    - Microsoft.VSTS.Scheduling.StoryPoints
    - Custom.StoryPointsActual
    - Custom.TestNotesforQA
```

Extract from the response:

- `System.Title` — for PR title
- `Microsoft.VSTS.Scheduling.StoryPoints` — planned story points (baseline for Step 10)
- `Custom.StoryPointsActual` — if already set, report it and skip re-proposal in Step 10 unless the user asks to update
- `System.State` — only transition in Step 9 if not already `Code Review`
- `Custom.TestNotesforQA` — preserve existing value if already populated; only draft new notes when empty

**Fallback (Azure CLI):**

```bash
az boards work-item show --id {numeric_id} --organization https://absinc.visualstudio.com --output json
```

**PR title:** `WI{number}: {System.Title}` — always use the colon separator. Do not use conventional-commit format for the PR title.

## Step 3 — Check for duplicate PR

**ADO MCP:** `repo_list_pull_requests_by_repo_or_project` with both `project` and `repositoryId` (schema requires one of them; pass both):

```
CallMcpTool server=user-ado toolName=repo_list_pull_requests_by_repo_or_project
  project: "Net"
  repositoryId: "{repo-name}"
  status: "Active"
  sourceRefName: "refs/heads/WI{number}"
```

**Azure CLI fallback:**

```bash
az repos pr list --organization https://absinc.visualstudio.com --project Net --repository {repo-name} --source-branch WI{number} --status active --output json
```

If an active PR exists, return its URL and ID — do not create a duplicate. You may still run Steps 9–11 if the user wants WI updates for an existing PR.

## Step 4 — Build change summary from git

Run these in parallel from the repository root:

```bash
git status
git branch -vv
git fetch origin dev
git log origin/dev..HEAD --oneline
git diff --stat origin/dev...HEAD
```

Compose the PR **description** using Summary + Test plan (skip Changes table when diff already shows files):

```markdown
## Summary
- [1-3 bullets: what changed and why, from commits and diff]

## Test plan
- [ ] [Tests run or manual steps from commits/user context]
```

Keep the description under **4000 characters** (MCP limit).

Resolve repository name from `git remote get-url origin` (last path segment, strip `.git`).

Note whether the branch needs pushing — report in the proposal but do not push yet.

Retain diff stats and commit count — they feed the Story Points Actual proposal in Step 10.

## Step 5 — Propose PR (stop here)

**If reviewer mirroring was requested (target ≠ `dev`):** run policy discovery now so the Reviewers row is accurate. Cache the resulting required/optional sets; Step 8.5 will apply them without re-running discovery.

Present the full PR preview and **wait for explicit approval**. Do not push or create anything in this step.

```markdown
## Proposed ADO Pull Request

| Field | Value |
|-------|-------|
| Work item | WI{number} |
| Repository | {repo-name} |
| Source | WI{number} |
| Target | dev |
| Title | WI{number}: {System.Title} |
| Planned story points | {planned or "not set"} |
| Reviewers (mirrored from dev) | {list required} (required); {list optional} (optional) — omit row if mirroring not requested; note any path-scoped policies excluded |

### Description
{full markdown from Step 4}

### Branch status
- [ ] Branch needs push ({N} commits ahead of origin)
- [ ] Branch already on remote and up to date

---
Reply **approve** (or edit title/description) to push and create this PR.
```

Only proceed to Steps 6–8 after clear PR approval.

## Step 6 — Push branch (after PR approval only)

Confirm the current branch is `WI{number}`.

- No upstream or local commits ahead of remote → `git push -u origin WI{number}`
- Already pushed and up to date → skip push, continue to Step 7

**Never** force-push unless the user explicitly requests it.
**Never** update git config.
**Never** force-push to `dev` or `main`.

## Step 7 — Create PR (after PR approval only)

### Option A — ADO MCP (preferred)

```
CallMcpTool server=user-ado toolName=repo_create_pull_request
  project: "Net"
  repositoryId: "{repo-name}"
  sourceRefName: "refs/heads/WI{number}"
  targetRefName: "refs/heads/dev"
  title: "WI{number}: {System.Title}"
  description: "{markdown from Step 4}"
  workItems: "{numeric_id}"
```

Pass multiple work items as space-separated IDs in `workItems`.

Prefer linking via `workItems` on create. If the link is missing after create, recover with `wit_link_work_item_to_pull_request` using project **ID** and repository **GUID** (not names):

```
CallMcpTool server=user-ado toolName=wit_link_work_item_to_pull_request
  projectId: "{project-guid}"
  repositoryId: "{repo-guid}"
  pullRequestId: {pr-id}
  workItemId: {numeric_id}
```

Repo GUID: `repo_get_repo_by_name_or_id` (MCP) or `az repos show --repository {repo-name} --query id -o tsv`.

### Option B — Azure CLI fallback

**Prerequisites:**

```bash
az extension add --name azure-devops --yes   # if not installed
```

Set `AZURE_DEVOPS_EXT_PAT` to a PAT with **Code (Read & Write)** and **Work Items (Read & Write)**. The extension picks up the PAT automatically; no `az login` required.

**PowerShell (Windows):**

```powershell
$desc = @'
## Summary
- ...

## Test plan
- [ ] ...
'@

az repos pr create `
  --organization https://absinc.visualstudio.com `
  --project Net `
  --repository {repo-name} `
  --source-branch WI{number} `
  --target-branch dev `
  --title "WI{number}: {ticket title}" `
  --description $desc `
  --work-items {numeric_id} `
  --output json
```

**Bash:**

```bash
az repos pr create \
  --organization https://absinc.visualstudio.com \
  --project Net \
  --repository {repo-name} \
  --source-branch WI{number} \
  --target-branch dev \
  --title "WI{number}: {ticket title}" \
  --description "$(cat <<'EOF'
## Summary
- ...

## Test plan
- [ ] ...
EOF
)" \
  --work-items {numeric_id} \
  --output json
```

## Step 8 — Verify PR

Confirm via MCP or CLI. Capture PR URL and PR ID.

```
CallMcpTool server=user-ado toolName=repo_get_pull_request_by_id
  repositoryId: "{repo-name}"
  project: "Net"
  pullRequestId: {pr-id}
  includeWorkItemRefs: true
```

CLI: `az repos pr show --id {id} --organization https://absinc.visualstudio.com --project Net --repository {repo-name}`

If work item refs are empty, run the WI-link recovery from Step 7.

## Step 8.5 — Mirror dev reviewers (opt-in, non-dev targets only)

**Skip when:** mirroring was not requested, the target is `dev`, or no enabled `Required reviewers` policies were found.

**Policy source branch:** `dev` (default).

**Discovery (Azure CLI):** needs repo GUID first (`repo_get_repo_by_name_or_id` or `az repos show`).

```bash
az repos policy list \
  --organization https://absinc.visualstudio.com \
  --project Net \
  --repository-id {repo-guid} \
  --branch dev \
  --output json \
| jq '[.[]
       | select(.type.id=="fd2167ab-b0be-447a-8ec8-39368250530e")
       | select(.isEnabled==true)
       | select(.settings.filenamePatterns==null)
       | {isBlocking, ids: .settings.requiredReviewerIds}]'
```

Iterate **every** enabled `Required reviewers` policy (type id above; match primarily by `type.displayName == "Required reviewers"`). Disabled and path-scoped (`settings.filenamePatterns` present) policies are excluded. Report path-scoped exclusions as "not mirrored (path-scoped)".

Build the set: required = `isBlocking == true`; optional = `isBlocking == false`; dedupe; required wins; drop PR author id. Group/container identities are valid.

Use the cached set from Step 5 when discovery already ran. Do not re-run discovery.

**Apply (REST PUT, primary)** — once per reviewer. `isRequired: true` for required; `isRequired: false` for optional.

PowerShell:

```powershell
$pat = $env:AZURE_DEVOPS_EXT_PAT
$headers = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat")) }
$body = @{ isRequired = $true } | ConvertTo-Json   # use $false for optional reviewers
Invoke-RestMethod -Method Put -Headers $headers -ContentType "application/json" -Body $body `
  -Uri "https://absinc.visualstudio.com/Net/_apis/git/repositories/$repoId/pullRequests/$prId/reviewers/$reviewerId?api-version=7.1"
```

Bash/curl:

```bash
curl -sS -u ":$AZURE_DEVOPS_EXT_PAT" -X PUT \
  -H "Content-Type: application/json" \
  -d '{"isRequired": true}' \
  "https://absinc.visualstudio.com/Net/_apis/git/repositories/$REPO_ID/pullRequests/$PR_ID/reviewers/$REVIEWER_ID?api-version=7.1"
```

**MCP fallback:** `repo_update_pull_request_reviewers` (action `add`) adds everyone as optional. Warn: "Could not set required flag — `AZURE_DEVOPS_EXT_PAT` unavailable."

**Edge cases:** target `dev` → skip (branch policy adds reviewers); nothing to mirror → note and continue; after apply report "Attached N required, M optional reviewers."

## Step 9 — Move work item to Code Review

Run after PR create and verify. Skip state transition if already `Code Review` — still set Test Notes for QA if empty.

Draft Test Notes for QA from the PR test plan, test commands run, and manual QA steps. Reference the PR number. Use `N/A` only when there is truly no QA impact.

Do not overwrite `Custom.TestNotesforQA` unless the user requests it.

### Option A — ADO MCP (preferred)

Schema default `op` is `add`. Use `replace`:

```json
{
  "id": 18954,
  "updates": [
    { "op": "replace", "path": "/fields/System.State", "value": "Code Review" },
    { "op": "replace", "path": "/fields/Custom.TestNotesforQA", "value": "PR #12057. dotnet test Tmo.WebForms.HttpTests: all passed. Manual: verify L1-L5 S17 payoff scenarios." }
  ]
}
```

Omit the `System.State` update if already in `Code Review`.

### Option B — Azure CLI fallback

```bash
az boards work-item update \
  --id {numeric_id} \
  --organization https://absinc.visualstudio.com \
  --fields "System.State=Code Review" "Custom.TestNotesforQA=PR #{id}. ..."
```

If already in Code Review, update only `Custom.TestNotesforQA` when empty.

Continue immediately to Step 10 — do not wait for user input between Steps 9 and 10.

## Step 10 — Propose Story Points Actual (stop here)

Skip if `Custom.StoryPointsActual` is already set — report existing value and ask whether to change.

**Estimation rubric** — start from planned story points, adjust using git signals from Step 4:

| Signal | Use |
|--------|-----|
| Planned points | Baseline |
| `git diff --stat` lines/files | Complexity proxy |
| Commit count | Scope indicator |
| Test additions / integration surface | Upward adjustment |
| Scope reduction / mostly config or wiring | Downward adjustment |

Rules: whole numbers only; match planned when straightforward; +1 to +3 when more complex (cap 13); -1 to -2 when smaller (floor 1). Always show planned vs proposed actual with 2–3 bullet rationale.

Present this proposal and **wait for explicit approval** before Step 11:

```markdown
## Proposed Story Points Actual

| Field | Value |
|-------|-------|
| Work item | WI{number} |
| Planned (Story Points) | {planned} |
| Proposed actual | {proposed} |

### Rationale
- {bullet from diff/commits}
- {bullet from tests or complexity}

---
Reply **approve** (or give a different number, e.g. `actual: 5`) to update Story Points Actual on the ticket.
```

## Step 11 — Update Story Points Actual (after story points approval only)

Use the user's number if they gave a different value (e.g. `actual: 3`).

### Option A — ADO MCP (preferred)

```json
{
  "id": 18954,
  "updates": [
    { "op": "replace", "path": "/fields/Custom.StoryPointsActual", "value": "5" }
  ]
}
```

### Option B — Azure CLI fallback

```bash
az boards work-item update \
  --id {numeric_id} \
  --organization https://absinc.visualstudio.com \
  --fields "Custom.StoryPointsActual={proposed}"
```

Re-fetch to confirm `Custom.StoryPointsActual` and `System.State`.

## Final report

Return: PR URL and ID, linked WI, branches, WI state, Test Notes summary, Story Points Actual (planned → actual), reviewers attached if mirrored ("Attached N required, M optional" or "not requested").

## Critical rules

| Rule | Detail |
|------|--------|
| **Two approval gates** | PR approval before push/create/Code Review; story points approval before updating `Custom.StoryPointsActual` |
| MCP schemas first | Read tool descriptors before calling |
| Work item link | Always associate the WI on create; recover with project ID + repo GUID if missing |
| PR title format | `WI{number}: {ticket title}` — not conventional commits |
| Commit messages | Still follow conventional commits on the branch |
| No duplicate PRs | Report existing active PR instead of creating another |
| No git config changes | Never run `git config` |
| No force-push to protected branches | Never force-push `dev`/`main` |
| Preserve existing Test Notes | Do not overwrite unless user requests |
| Skip story points if set | Report existing `Custom.StoryPointsActual` unless user asks to update |
| Mirror reviewers | Only when caller explicitly asks; only for non-`dev` targets; iterate **all** enabled `Required reviewers` policies on `dev`; required flag needs REST PUT (`isRequired` true/false); MCP fallback adds as optional only |
| PR body | Summary + Test plan; skip Changes table when the diff already shows files |
