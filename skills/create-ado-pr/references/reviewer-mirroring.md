# Mirror dev reviewers (Step 8.5)

Opt-in; non-`dev` targets only. No separate approval — runs under the PR approval gate after create.

## Skip when

- Mirroring was not requested
- Target is `dev` (branch policy adds reviewers)
- No enabled `Required reviewers` policies found

**Policy source branch:** `dev` (default).

## Discovery (run in Step 5 when mirroring requested)

Needs repo GUID first (`repo_repository` action `get`, or `az repos show`).

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

Cache the set from Step 5; do not re-run discovery in Step 8.5.

## Apply (REST PUT, primary)

Once per reviewer. `isRequired: true` for required; `isRequired: false` for optional.

**PowerShell:**

```powershell
$pat = $env:AZURE_DEVOPS_EXT_PAT
$headers = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat")) }
$body = @{ isRequired = $true } | ConvertTo-Json   # use $false for optional reviewers
Invoke-RestMethod -Method Put -Headers $headers -ContentType "application/json" -Body $body `
  -Uri "https://absinc.visualstudio.com/Net/_apis/git/repositories/$repoId/pullRequests/$prId/reviewers/$reviewerId?api-version=7.1"
```

**Bash/curl:**

```bash
curl -sS -u ":$AZURE_DEVOPS_EXT_PAT" -X PUT \
  -H "Content-Type: application/json" \
  -d '{"isRequired": true}' \
  "https://absinc.visualstudio.com/Net/_apis/git/repositories/$REPO_ID/pullRequests/$PR_ID/reviewers/$REVIEWER_ID?api-version=7.1"
```

**MCP fallback:** `repo_update_pull_request_reviewers` (action `add`) adds everyone as optional. Warn: "Could not set required flag — `AZURE_DEVOPS_EXT_PAT` unavailable."

## Edge cases

- Nothing to mirror → note and continue
- After apply → report "Attached N required, M optional reviewers."
