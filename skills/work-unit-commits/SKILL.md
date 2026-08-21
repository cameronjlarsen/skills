---
name: work-unit-commits
description: "Plan commits as reviewable work units. Trigger: implementation, commit splitting, stacked PRs, or keeping tests and docs with code."
license: Apache-2.0
metadata:
  author: cameron-larsen
  version: "1.1"
  source: "Adapted from Gentle AI work-unit-commits (gentleman-programming, Apache-2.0). SDD hooks removed."
---

# Work-unit commits

Load this skill when deciding what belongs in each commit or PR.

## Hard rules

| Rule | Requirement |
|------|-------------|
| Commit by work unit | A commit is one deliverable behavior, fix, migration, or docs unit. |
| Do not commit by file type | Avoid `models`, then `services`, then `tests` if none works alone. |
| Keep tests with code | Tests belong in the same commit as the behavior they verify. |
| Keep docs with the user-visible change | Docs belong with the feature or workflow they explain. |
| Tell a story | A reviewer should understand why each commit exists from its diff and message. |
| Future PR-ready | Each commit should be a candidate stacked PR if the change grows. |
| Conventional commit messages | Outcome in the message, not a file list. PR titles still follow `create-ado-pr` (`WI{n}: {ticket title}`). |

This is the commit-shaping complement to pstack `principle-sequence-verifiable-units`. That principle is the why. This skill is the split.

## Checklist

Before committing, confirm:

- [ ] The commit has one clear purpose.
- [ ] The repo still makes sense after applying only this commit.
- [ ] Tests or docs for this unit are included when relevant.
- [ ] Rollback is reasonable without reverting unrelated work.
- [ ] The commit message explains the outcome, not the file list.

## Split examples

| Weak split | Better work-unit split |
|------------|------------------------|
| `add models` | `feat(auth): add token validation domain model and tests` |
| `add services` | `feat(auth): wire token validation into login flow` |
| `add tests` | Tests included with each behavior commit |
| `update docs` | Docs included with the user-facing change they explain |

## PR size

If the change is heading past about 400 lines, promote commits or groups of commits into stacked PRs before opening.

1. Build the smallest independent work unit.
2. Include verification for that unit.
3. Commit it.
4. If the PR is getting large, split the stack instead of stuffing more in.

## Commands

```bash
git diff --stat
git diff --cached --stat
git log --oneline -5
```
