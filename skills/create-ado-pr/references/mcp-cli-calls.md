# MCP and Azure CLI call recipes

Prefer ADO MCP on server `user-azure-devops`. Read live tool schemas before calling; map if names drift. Fall back to Azure CLI when MCP is unavailable.

Org: `https://absinc.visualstudio.com` · Project: `Net`

---

## Step 2 — Fetch work item

**MCP:**

```
CallMcpTool server=user-azure-devops toolName=wit_work_item
  action: "get"
  id: {numeric_id}
  project: "Net"
  fields:
    - System.Title
    - System.State
    - System.WorkItemType
    - Microsoft.VSTS.Scheduling.StoryPoints
    - Custom.StoryPointsActual
    - Custom.TestNotesforQA
    - Custom.FeatureFlagInUse
```

Extract: title (PR title); type; planned points (may be absent); existing actual (skip Step 10 re-proposal unless user asks); state (skip Code Review transition if already set); Test Notes (preserve if populated); Feature Flag (set in Step 9 if unset).

**CLI fallback:**

```bash
az boards work-item show --id {numeric_id} --organization https://absinc.visualstudio.com --output json
```

PR title: `WI{number}: {System.Title}` — colon separator; not conventional-commit format.

---

## Step 3 — List active PRs for source branch

**MCP** (pass both `project` and `repositoryId`):

```
CallMcpTool server=user-azure-devops toolName=repo_pull_request
  action: "list"
  project: "Net"
  repositoryId: "{repo-name}"
  status: "Active"
  sourceRefName: "refs/heads/WI{number}"
```

**CLI fallback:**

```bash
az repos pr list --organization https://absinc.visualstudio.com --project Net --repository {repo-name} --source-branch WI{number} --status active --output json
```

If active PR exists: return URL and ID — do not create a duplicate. Steps 9–11 may still run if the user wants WI updates for an existing PR.

---

## Step 7 — Create PR

### MCP (preferred)

```
CallMcpTool server=user-azure-devops toolName=repo_pull_request_write
  action: "create"
  project: "Net"
  repositoryId: "{repo-name}"
  sourceRefName: "refs/heads/WI{number}"
  targetRefName: "refs/heads/dev"
  title: "WI{number}: {System.Title}"
  description: "{markdown from Step 4}"
  workItems: "{numeric_id}"
```

Multiple work items: space-separated IDs in `workItems`.

If WI link missing after create, recover with project **ID** and repository **GUID**:

```
CallMcpTool server=user-azure-devops toolName=wit_work_item_link_write
  action: "link_to_pull_request"
  projectId: "{project-guid}"
  repositoryId: "{repo-guid}"
  pullRequestId: {pr-id}
  workItemId: {numeric_id}
```

Repo GUID:

```
CallMcpTool server=user-azure-devops toolName=repo_repository
  action: "get"
  project: "Net"
  repositoryNameOrId: "{repo-name}"
```

Or CLI: `az repos show --repository {repo-name} --query id -o tsv`.

### Azure CLI fallback

Prerequisites: `az extension add --name azure-devops --yes` if needed. Set `AZURE_DEVOPS_EXT_PAT` with Code (Read & Write) and Work Items (Read & Write). Extension picks up PAT; no `az login` required.

**PowerShell:**

```powershell
$desc = @'
## TL;DR
...

## Review
- Start here: ...
- Lower priority: none
- Risk: low

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
## TL;DR
...

## Review
- Start here: ...
- Lower priority: none
- Risk: low

## Test plan
- [ ] ...
EOF
)" \
  --work-items {numeric_id} \
  --output json
```

---

## Step 8 — Verify PR

**MCP:**

```
CallMcpTool server=user-azure-devops toolName=repo_pull_request
  action: "get"
  repositoryId: "{repo-name}"
  project: "Net"
  pullRequestId: {pr-id}
  includeWorkItemRefs: true
```

**CLI:** `az repos pr show --id {id} --organization https://absinc.visualstudio.com --project Net --repository {repo-name}`

If work item refs empty, run WI-link recovery from Step 7.

---

## Step 9 — Code Review + Test Notes + Feature Flag

Draft Test Notes from PR test plan, commands run, and manual QA steps. Reference the PR number. Use `N/A` only when there is truly no QA impact. Do not overwrite `Custom.TestNotesforQA` unless the user requests it.

`Custom.FeatureFlagInUse` must be the string `Yes` or `No` (boolean rejected). Include it in the same update as State when transitioning to Code Review — required for Dev Task.

Schema default `op` is `add`. Use `replace`:

```
CallMcpTool server=user-azure-devops toolName=wit_work_item_write
  action: "update"
  id: {numeric_id}
  project: "Net"
  updates:
    - op: "replace"
      path: "/fields/System.State"
      value: "Code Review"
    - op: "replace"
      path: "/fields/Custom.TestNotesforQA"
      value: "PR #12057. dotnet test Tmo.WebForms.HttpTests: all passed. Manual: verify L1-L5 S17 payoff scenarios."
    - op: "replace"
      path: "/fields/Custom.FeatureFlagInUse"
      value: "Yes"
```

Omit `System.State` if already `Code Review`. Omit Test Notes if already populated. Still set Feature Flag when unset.

**CLI:**

```bash
az boards work-item update \
  --id {numeric_id} \
  --organization https://absinc.visualstudio.com \
  --fields "System.State=Code Review" "Custom.TestNotesforQA=PR #{id}. ..." "Custom.FeatureFlagInUse=Yes"
```

---

## Step 11 — Story Points Actual

Use the user’s number if they gave a different value (e.g. `actual: 3`).

```
CallMcpTool server=user-azure-devops toolName=wit_work_item_write
  action: "update"
  id: {numeric_id}
  project: "Net"
  updates:
    - op: "replace"
      path: "/fields/Custom.StoryPointsActual"
      value: "5"
```

**CLI:**

```bash
az boards work-item update \
  --id {numeric_id} \
  --organization https://absinc.visualstudio.com \
  --fields "Custom.StoryPointsActual={proposed}"
```

Re-fetch to confirm `Custom.StoryPointsActual` and `System.State`.
