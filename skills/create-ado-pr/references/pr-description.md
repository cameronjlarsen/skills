# PR description (reviewer-first)

Compose the ADO PR body from commits + `git diff` so a reviewer knows intent, where to start, and risk. Cap at **4000 characters** (MCP limit). Skip a Changes table when the diff already shows files.

## Required shape

```markdown
## TL;DR
{2–4 sentences: what changed, why, and the main constraint (flag, opt-in, parity, etc.). Must match the actual diff — not a restatement of the ticket title.}

## Review
- Start here: {1–3 core files or areas and why they matter}
- Lower priority: {mechanical, generated, wiring, or "none"}
- Risk: {behavior change, flag/rollout, migration, empty-set, SQL, etc. — or "low"}

## Test plan
- [ ] {scenario that would catch the main risk}
- [ ] {flag-off / rollback / parity if applicable}
- [ ] {tests already run, if any}
```

## Writing rules

| Do | Don't |
|----|--------|
| Lead with outcome and constraint | Bullet a commit changelog |
| Name concrete entry-point files | List every touched path |
| Tie Test plan items to Risk | Generic "manually test the page" |
| Note flag-off / legacy parity when relevant | Paste the WI description verbatim |
| Keep TL;DR faithful to the diff | Inflate scope or hide risky behavior |

## Optional

- Link design notes or prior PRs only when they explain intent.
- If the PR is too large to orient with this template, say so in Risk and recommend splitting — do not pad the description instead.
