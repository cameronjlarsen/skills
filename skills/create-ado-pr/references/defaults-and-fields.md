# Defaults and field reference (TMO / absinc)

Override target branch, project, or org only when the user specifies.

## Defaults

| Setting | Default |
|---------|---------|
| Organization | `https://absinc.visualstudio.com` |
| Project | `Net` |
| Target branch | `dev` (`refs/heads/dev`) |
| Source branch | `WI{number}` (`refs/heads/WI{number}`) |
| PR title | `WI{number}: {System.Title}` |
| Work item link | Required on create |

## Field reference (Net)

| UI label | Reference name | Notes |
|----------|----------------|-------|
| Work Item Type | `System.WorkItemType` | Fetch in Step 2; drives required fields on state change |
| Title | `System.Title` | PR title source |
| State | `System.State` | Target: `Code Review` |
| Story Points (planned) | `Microsoft.VSTS.Scheduling.StoryPoints` | Often unset on Dev Task — treat as optional |
| Story Points Actual | `Custom.StoryPointsActual` | Works on User Story and Dev Task |
| Test Notes for QA | `Custom.TestNotesforQA` | Preserve if populated |
| Feature Flag In Use | `Custom.FeatureFlagInUse` | String `Yes` / `No` only — boolean rejected |

### Type differences (Code Review)

| Type | Code Review notes |
|------|-------------------|
| User Story | Planned points usually present; still set Feature Flag In Use |
| Dev Task | Planned points often absent; Feature Flag In Use required with State→Code Review |

Set Feature Flag from the change: `Yes` if behind a flag, else `No`. Always string.

## WI ID resolution

Parse from the current branch name with regex `WI(\d+)` (case-insensitive).

| Input | Numeric ID | Branch prefix |
|-------|------------|---------------|
| Branch `WI18954` | `18954` | `WI18954` |
| User says `18954` | `18954` | `WI18954` |
| User says `WI18954` | `18954` | `WI18954` |

If the branch does not match and the user did not supply an ID, ask before continuing.

## Story Points Actual estimation rubric

Start from planned story points when present; if absent, show planned as `unset` and estimate from git signals alone:

| Signal | Use |
|--------|-----|
| Planned points | Baseline when present |
| `git diff --stat` lines/files | Complexity proxy |
| Commit count | Scope indicator |
| Test additions / integration surface | Upward adjustment |
| Scope reduction / mostly config or wiring | Downward adjustment |

Rules: whole numbers only; match planned when straightforward; +1 to +3 when more complex (cap 13); -1 to -2 when smaller (floor 1). Always show planned vs proposed actual with 2–3 bullet rationale.
